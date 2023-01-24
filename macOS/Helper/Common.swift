//
//  Common.swift
//  Swimbols
//
//  Created by Imthathullah M on 11/10/20.
//

import AppKit
import CanvasKit
import Cocoa
import SwiftUI

public struct ActivityIndicator: NSViewRepresentable {
  public typealias NSViewType = NSProgressIndicator
  
  @Binding var isAnimating: Bool
  
  //    var progressIndicator = NSProgressIndicator()
  
  public func makeNSView(context: Context) -> NSProgressIndicator {
    let progressIndicator = NSProgressIndicator()
    progressIndicator.isIndeterminate = true
    progressIndicator.style = .spinning
    return progressIndicator
  }
  
  public func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
    if isAnimating {
      nsView.startAnimation(nil)
    } else {
      nsView.stopAnimation(nil)
    }
  }
}

public struct CardButtonStyle: ButtonStyle {
  let backgroundColor: Color
  let textColor: Color
  let height: CGFloat
  
  public init(backgroundColor: Color = .blue,
              textColor: Color = .white,
              height: CGFloat = .averageTouchSize) {
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    self.height = height
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    ZStack {
      bgColor(for: configuration).cornerRadius(.small)
      configuration.label
        .foregroundColor(self.fgColor(for: configuration))
    }
    .frame(height: height)
    .padding(.vertical, .small)
  }
  
  func fgColor(for configuration: Configuration) -> Color {
    configuration.isPressed ? textColor.opacity(0.6) : textColor
  }
  
  func bgColor(for configuration: Configuration) -> Color {
    configuration.isPressed ? backgroundColor.opacity(0.3) : backgroundColor
  }
}

extension View {
  func centerHorizontally() -> some View {
    HStack {
      Spacer()
      self
      Spacer()
    }
  }
  
  func simpleAlert(isPresented: Binding<Bool>, title: String = "Alert", message: String) -> some View {
    return self.alert(isPresented: isPresented, content: {
      Alert(title: Text(title), message: Text(message))
    })
  }
  
  func showInWindow() {
    let window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 1600, height: 1600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.center()
    window.contentViewController = NSHostingController(rootView: self)
    window.makeKeyAndOrderFront(nil)
  }
}

/// the co-ordinate system is flipped, thus making it similar to iOS
class FlippedView: NSView {
  override var isFlipped: Bool { true }
}

class SDTableViewController: NSViewController,
                             NSTableViewDelegate,
                             NSTableViewDataSource {
  lazy var scrollView = NSScrollView()
  lazy var tableView = EditableTableView()
  
  override func loadView() {
    self.view = scrollView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView.minWidth(240)
    scrollView.minHeight(330)
    
    configure(tableView, in: scrollView)
    tableView.delegate = self
    tableView.dataSource = self
  }
}

class SeperatorView: NSView {
  var thickness: CGFloat
  
  init(thickness: CGFloat) {
    self.thickness = thickness
    super.init(frame: NSRect())
    self.fixHeight(thickness)
    
    self.wantsLayer = true
    self.layer?.backgroundColor = NSColor.separatorColor.cgColor
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public class Constant { }

public extension Constant {
  static var sidebarWidth: CGFloat { 140 }
  static var collectionCellHeight: CGFloat { 128 }
  static var collectionCellWidth: CGFloat { 100 }
  
  static var appliedModifiers: String { "Applied modifiers" }
  static var availableModifiers: String { "Available modifiers" }
}

class Message {
  static func categoryMissing(at index: Int) -> String {
    "Unable to fetch category from CoreData at index \(index)"
  }
  
  static func iconMissing(at index: Int) -> String {
    "Unable to fetch icon from CoreData at index \(index)"
  }
  
  static var splitViewMissing: String {
    "Unable to reach parent split view controller"
  }
  
  static var collectionCellFailure: String {
    "Unable to make collection view cell"
  }
  
  static var categoryMissing: String {
    "Category not set to display the icons in collection view"
  }
  
  static func delegateMissing(for className: String) -> String {
    "Delegate not set for \(className)"
  }
}

class EditableTableView: NSTableView {
  override func validateProposedFirstResponder(_ responder: NSResponder, for event: NSEvent?) -> Bool {
    return true
  }
}

extension NSTextField {
  static func plain(with string: String = "") -> NSTextField {
    let field = NSTextField(frame: NSRect())
    field.stringValue = string
    //        field.placeholderString = ""
    field.isEditable = false
    field.drawsBackground = false
    field.isBordered = false
    return field
  }
}

extension NSPopUpButton {
  func addOptions<T: CaseIterable & Displayable>(from enumeration: T) {
    for option in T.self.allCases {
      addItem(withTitle: option.displayValue)
      if option.displayValue == enumeration.displayValue {
        selectItem(at: self.itemTitles.count - 1)
      }
    }
  }
}

extension NSViewController {
  func configure(_ tableView: NSTableView, in scrollView: NSScrollView, columnWidth: CGFloat = Constant.sidebarWidth) {
    tableView.frame = scrollView.bounds
    tableView.headerView = nil
    //        tableView.style = .sourceList
    //        tableView.usesAutomaticRowHeights = true
    scrollView.backgroundColor = NSColor.clear
    scrollView.drawsBackground = false
    //        tableView.backgroundColor = NSColor.clear
    //        tableView.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
    
    scrollView.documentView = tableView
    scrollView.hasHorizontalScroller = false
    scrollView.hasVerticalScroller = true
  }
}

public extension NSTableView {
  func addColumn(withID id: String, header: String? = nil, width: CGFloat = Constant.sidebarWidth) {
    let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
    col.minWidth = width
    
    if let header = header {
      if self.headerView == nil {
        self.headerView = NSTableHeaderView(frame: NSRect(x: 0, y: 0, width: 100, height: 30))
      }
      col.headerCell.stringValue = header
    }
    
    self.addTableColumn(col)
  }
}

public extension NSApplication {
  func toggleSidebar() {
    NSApplication.shared.keyWindow?.firstResponder?.tryToPerform(
      #selector(NSSplitViewController.toggleSidebar(_:)),
      with: nil
    )
  }
}

public extension String {
  func log(file: String = #file,
           functionName: String = #function,
           lineNumber: Int = #line) {
    print("[SWIMBOLS_MAC] \(URL(fileURLWithPath: file).lastPathComponent)-\(functionName):\(lineNumber)  \(self)")
  }
}

public extension Array {
  subscript(safe index: Int) -> Element? {
    if index < count {
      return self[index]
    }
    
    return nil
  }
}
