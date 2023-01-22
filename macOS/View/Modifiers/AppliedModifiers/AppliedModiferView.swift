//
//  AppliedModifersView.swift
//  Swimbols
//
//  Created by Imthathullah M on 13/10/20.
//

import CanvasKit
import Cocoa

protocol AppliedModifierDelegate: class {
  func takeUp(_ modifier: Modifier, from index: Int)
  func takeDown(_ modifier: Modifier, from index: Int)
  func delete(_ modifier: Modifier, from index: Int)
}

class AppliedModifierView: FlippedView {
  lazy var popupButton = NSPopUpButton(frame: NSRect(), pullsDown: false)
  lazy var stepper = NSStepper(frame: NSRect())
  lazy var valueField = NSTextField()
  lazy var nameField = NSTextField.plain()
  lazy var nameFieldTwo = NSTextField.plain()
  lazy var horizontalStack = NSStackView()
  lazy var horizontalStackTwo = NSStackView()
  lazy var verticalStack = NSStackView()
  
  lazy var topSeperator = SeperatorView(thickness: 0.7)
  lazy var bottomSeperator = SeperatorView(thickness: 0.7)
  
  weak var delegate: AppliedModifiersVC?
  
  var row: Int
  var double: Double = 0
  var modifiers: [Modifier] { SFPreferences.shared.model.modifiers }
  var currentModifier: Modifier { modifiers[row] }
  
  init(_ modifier: Modifier, row: Int) {
    self.row = row
    super.init(frame: NSRect(x: 0, y: 0, width: 120, height: 88))
    setModifier(modifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func menu(for event: NSEvent) -> NSMenu? {
    guard event.type == .rightMouseDown else {
      return nil
    }
    
    let menu = NSMenu(title: "options")
    
    if row > 0 {
      let upItem = NSMenuItem(title: "Move up", action: #selector(goUp), keyEquivalent: "")
      upItem.image = NSImage(systemSymbolName: "arrow.up", accessibilityDescription: nil)
      menu.addItem(upItem)
    }
    
    if row < modifiers.count - 1 {
      let downItem = NSMenuItem(title: "Move down", action: #selector(goDown), keyEquivalent: "")
      downItem.image = NSImage(systemSymbolName: "arrow.down", accessibilityDescription: nil)
      menu.addItem(downItem)
    }
    
    if modifiers.count != 1 {
      menu.addItem(NSMenuItem.separator())
    }
    
    let deleteItem = NSMenuItem(title: "Delete", action: #selector(delete), keyEquivalent: "")
    deleteItem.image = NSImage(systemSymbolName: "trash.fill", accessibilityDescription: nil)
    menu.addItem(deleteItem)
    
    menu.delegate = self
    return menu
  }
  
  @objc func goUp() {
    delegate?.takeUp(currentModifier, from: row)
  }
  
  @objc func goDown() {
    delegate?.takeDown(currentModifier, from: row)
  }
  
  @objc func delete() {
    delegate?.delete(currentModifier, from: row)
  }
  
  func configureViews(for modifier: Modifier) {
  }
  
  func layoutViews(for modifier: Modifier) {
    self.fixHeight(88)
    
    switch modifier.type {
    case .rotation, .fontSize: addVerticalStack()
    default: addHorizontalStack()
    }
    
    if row == 0 {
      self.addSubview(topSeperator)
      topSeperator.alignTop(with: self, offset: .zero)
    }
    
    self.addSubview(bottomSeperator)
    bottomSeperator.alignBottom(with: self, offset: .zero)
  }
  
  func addHorizontalStack() {
    self.addSubview(horizontalStack)
    horizontalStack.alignEdges(with: self, offset: .zero)
    
    horizontalStack.orientation = .horizontal
    horizontalStack.distribution = .fill
  }
  
  func addVerticalStack() {
    self.addSubview(verticalStack)
    verticalStack.align([.top, .bottom], with: self, offset: .small)
    verticalStack.align([.leading, .trailing], with: self, offset: .zero)
    verticalStack.addArrangedSubview(horizontalStack)
    verticalStack.addArrangedSubview(horizontalStackTwo)
    
    horizontalStack.alignHorizontally(with: verticalStack, offset: .zero)
    horizontalStackTwo.alignHorizontally(with: verticalStack, offset: .zero)
    
    horizontalStack.fixHeight(25)
    horizontalStackTwo.fixHeight(25)
    verticalStack.minHeight(50)
    
    verticalStack.orientation = .vertical
    verticalStack.distribution = .fill
    
    horizontalStackTwo.orientation = .horizontal
    horizontalStackTwo.distribution = .fill
    
    horizontalStack.orientation = .horizontal
    horizontalStack.distribution = .fill
  }
  
  func setModifier(_ modifier: Modifier) {
    configureViews(for: modifier)
    layoutViews(for: modifier)
    switch modifier.type {
    case .imageScale(let value): configurePopup(for: value)
    case .background(let color), .foreground(let color): configureColorPopup(for: color)
    case .cornerRadius(let value): configureStepper(for: value, in: horizontalStack)
    case .padding(let insets): configureStepper(for: insets.leading, in: horizontalStack)
    case .rotation(let angle): configureStack(for: angle)
    case .fontSize(let value): configureFontStack(with: value)
    case .font(let value): configurePopup(for: value)
    case .clip(let shape): configurePopup(for: shape)
    }
  }
  
  func configureFontStack(with value: CVFontSizeWeight) {
    horizontalStack.addArrangedSubview(nameField)
    nameField.stringValue = "Font size"
    configureStepper(for: value.size, in: horizontalStack, addName: false)
    
    popupButton.addOptions(from: value.weight)
    horizontalStackTwo.addArrangedSubview(nameFieldTwo)
    nameFieldTwo.align(.top, with: horizontalStackTwo)
    nameFieldTwo.stringValue = "Font weight"
    horizontalStackTwo.addArrangedSubview(popupButton)
    popupButton.align(.top, with: horizontalStackTwo)
    setPopupTarget()
  }
  
  func configureStack(for angle: CVAngle) {
    horizontalStack.addArrangedSubview(nameField)
    nameField.stringValue = "Rotation value"
    configureStepper(for: CGFloat(angle.value), in: horizontalStack)
    
    popupButton.addOptions(from: angle.unit)
    horizontalStackTwo.addArrangedSubview(nameFieldTwo)
    nameFieldTwo.align(.top, with: horizontalStackTwo)
    nameFieldTwo.stringValue = "Rotation unit"
    horizontalStackTwo.addArrangedSubview(popupButton)
    popupButton.align(.top, with: horizontalStackTwo)
    setPopupTarget()
  }
  
  func configureStepper(for value: CGFloat, in hStack: NSStackView, addName: Bool = true) {
    if addName {
      configureNameField()
    }
    
    hStack.addArrangedSubview(valueField)
    valueField.doubleValue = Double(value)
    valueField.isEditable = true
    valueField.target = self
    valueField.action = #selector(valueFieldChanged)
    valueField.maxWidth(80)
    
    hStack.addArrangedSubview(stepper)
    stepper.doubleValue = Double(value)
    stepper.toolTip = currentModifier.type.displayValue
    stepper.maxValue = 100
    stepper.minValue = 0
    stepper.increment = 5
    stepper.target = self
    stepper.action = #selector(stepperChanged)
  }
  
  func configureColorPopup(for color: CVColor) {
    switch color {
    case .crossPlatform(let value):
      popupButton.addOptions(from: value)
    }
    
    configureNameField()
    configurePopupButton()
  }
  
  func configureImageScalePopup(for scale: CVImageScale) {
    popupButton.addOptions(from: scale)
    
    configureNameField()
    configurePopupButton()
  }
  
  func configurePopup<T: CaseIterable & Displayable>(for value: T) {
    popupButton.addOptions(from: value)
    
    configureNameField()
    configurePopupButton()
  }
  
  func configurePopupButton() {
    horizontalStack.addArrangedSubview(popupButton)
    
    setPopupTarget()
  }
  
  func setPopupTarget() {
    popupButton.target = self
    popupButton.action = #selector(popupChanged)
    popupButton.maxWidth(100)
  }
  
  func configureNameField() {
    horizontalStack.addArrangedSubview(nameField)
    nameField.stringValue = currentModifier.type.displayValue
  }
  
  @objc func stepperChanged() {
    valueField.doubleValue = stepper.doubleValue
    let float = CGFloat(valueField.doubleValue)
    if let newModifier = currentModifier.getModifier(withValue: float,
                                                     andOption: popupButton.indexOfSelectedItem) {
      SFPreferences.shared.model.modifiers[row] = newModifier
    }
  }
  
  @objc func valueFieldChanged() {
    stepper.doubleValue = valueField.doubleValue
    valueField.stringValue = "\(valueField.doubleValue)"
    let float = CGFloat(valueField.doubleValue)
    if let newModifier = currentModifier.getModifier(withValue: float, andOption: popupButton.indexOfSelectedItem) {
      SFPreferences.shared.model.modifiers[row] = newModifier
    }
  }
  
  @objc func popupChanged() {
    let index = popupButton.indexOfSelectedItem
    let float = CGFloat(valueField.doubleValue)
    if let newModifier = currentModifier.getModifier(withValue: float, andOption: index),
       row < modifiers.count {
      SFPreferences.shared.model.modifiers[row] = newModifier
    }
  }
  
  //    override func mouseEntered(with event: NSEvent) {
  //        "mouse is here".log()
  //        wantsLayer = true
  //        layer?.backgroundColor = NSColor.systemRed.cgColor
  //    }
}

extension AppliedModifierView: NSMenuDelegate {  
}
