//
//  AvailableModifiersVC.swift
//  Swimbols
//
//  Created by Imthathullah M on 13/10/20.
//

import CanvasKit
import Cocoa

protocol AvailableModifiersDelegate: AnyObject {
  func added(_ modifier: Modifier)
}

class AvailableModifiersVC: SDTableViewController {
  var allCases: [ModifierType] {
    [.padding(.equal(value: 10)),
     .imageScale(.medium),
     .font(.body),
     .fontSize(CVFontSizeWeight(size: 20, weight: .regular)),
     .background(.crossPlatform(.green)),
     .foreground(.crossPlatform(.blue)),
     .cornerRadius(10),
     .clip(.circle),
     .rotation(CVAngle(value: 15, unit: .degrees)),// ,
     //         .imageMode(.original)
    ]
  }
  
  var modifiers: [Modifier] {
    allCases.compactMap { type in
      if type.canAddMultiple || !SFPreferences.shared.model.hasModifier(of: type) { return Modifier(type: type) }
      
      return nil
    }
  }
  
  weak var delegate: AvailableModifiersDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.addColumn(withID: "available", header: "Available Modifiers")
    tableView.backgroundColor = NSColor.windowBackgroundColor
    tableView.style = .plain
  }
  
  // MARK: NSTableViewDataSource
  func numberOfRows(in tableView: NSTableView) -> Int {
    modifiers.count
  }
  
  // MARK: NSTableViewDelegate
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    AvailableModifierView(modifiers[row], row: row)
  }
  
  func tableView(_ tableView: NSTableView, heightOfRow: Int) -> CGFloat {
    return 30
  }
  
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    let modifier = modifiers[row]
    delegate?.added(modifier)
    
    if !modifier.type.canAddMultiple {
      tableView.reloadData()
    }
    return false
  }
}

class AvailableModifierView: FlippedView {
  lazy var iconView = NSImageView()
  lazy var nameField = NSTextField()
  lazy var plusButton = NSImageView()
  
  lazy var topSeperator = SeperatorView(thickness: 0.7)
  var row: Int
  
  init(_ modifier: Modifier, row: Int) {
    self.row = row
    super.init(frame: NSRect(x: 0, y: 0, width: 120, height: 44))
    configureViews()
    layoutViews()
    setModifier(modifier)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setModifier(_ modifier: Modifier) {
    nameField.stringValue = modifier.type.displayValue
    let image = NSImage(systemSymbolName: modifier.imageName, accessibilityDescription: nil)
    iconView.image = image?.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))
    
    nameField.drawsBackground = false
    nameField.isBordered = false
    nameField.isEditable = false
    nameField.lineBreakMode = .byTruncatingTail
  }
  
  func configureViews() {
    let image = NSImage(systemSymbolName: "plus.circle.fill", accessibilityDescription: nil)
    plusButton.image = image
    // ?.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))
  }
  
  func layoutViews() {
    //        self.fixWidth(180)
    
    self.addSubview(iconView)
    iconView.alignLeading(with: self, offset: .small)
    iconView.fixWidth(30)
    
    self.addSubview(nameField)
    nameField.align(.centerY, with: iconView)
    
    nameField.align(.leading, with: iconView, on: .trailing)
    nameField.fixWidth(120)
    //        nameField.fixHeight(36)
    
    self.addSubview(plusButton)
    plusButton.align(.trailing, with: self)
    plusButton.align(.centerY, with: iconView)
    plusButton.align(.leading, with: nameField, on: .trailing, offset: .large)
    plusButton.fixWidth(30)
    
    if row == 0 {
      self.addSubview(topSeperator)
      topSeperator.alignTop(with: self, offset: .zero)
    }
  }
}
