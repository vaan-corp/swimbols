//
//  Toolbar.swift
//  SUIToolbarPlay
//
//  Created by Bill So on 4/23/20.
//  Copyright © 2020 Bill So. All rights reserved.
//

import AppKit
import CanvasKit
import SwiftUI

extension NSToolbarItem.Identifier {
  static let sidebar = NSToolbarItem.Identifier(rawValue: "sidebar")
  static let favorites = NSToolbarItem.Identifier(rawValue: "GoToToday")
  static var search = NSToolbarItem.Identifier("search")
  static var updgrade = NSToolbarItem.Identifier("upgrade")
  static var moreOptions = NSToolbarItem.Identifier("moreOptions")
}

extension NSToolbar {
  static let taskListToolbar: NSToolbar = {
    let toolbar = NSToolbar(identifier: "TaskListToolbar")
    toolbar.displayMode = .iconOnly
    return toolbar
  }()
  
  static func removeUpgradeButton() {
    guard let toolbar = NSApplication.shared.windows.first?.toolbar else {
      "Unable to find the first window or the toolbar".log()
      return
    }
    
    guard let index = toolbar.items.firstIndex(where: { $0.itemIdentifier == .updgrade }) else {
      "Unable to find the upgrade item in the toolbar".log()
      return
    }
    
    "Removed upgrade item from index \(index) of the toolbar ".log()
    toolbar.removeItem(at: index)
  }
}

extension AppDelegate: NSToolbarDelegate {
  func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    toolbarItems
  }
  
  func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
    toolbarItems
  }
  
  var toolbarItems: [NSToolbarItem.Identifier] {
    guard ProductStore.shared.isPurchased else {
      return [.sidebar, .updgrade, .favorites, .search, .moreOptions]
    }
    
    return [.sidebar, .favorites, .search, .moreOptions]
  }
  
  func toolbar(
    _ toolbar: NSToolbar,
    itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
    willBeInsertedIntoToolbar flag: Bool
  ) -> NSToolbarItem? {
    switch itemIdentifier {
    case NSToolbarItem.Identifier.sidebar:
      let button = NSButton(
        image: NSImage(systemSymbolName: "sidebar.left", accessibilityDescription: nil)!,
        target: Router.shared.splitVC,
        action: #selector(Router.shared.splitVC.toggleSidebar)
      )
      button.bezelStyle = .texturedRounded
      //            button.keyEquivalent = "0"
      //            button.keyEquivalentModifierMask = .command
      let item = customToolbarItem(
        itemIdentifier: .sidebar,
        label: "Sidebar",
        paletteLabel: "Sidebar",
        toolTip: "Show/Hide Sidebar",
        itemContent: button
      )
      item?.isNavigational = true
      return item
    case NSToolbarItem.Identifier.favorites:
      let item = customToolbarItem(
        itemIdentifier: .sidebar,
        label: "Favorite",
        paletteLabel: "Favorite",
        toolTip: "Show/Hide favorite symbols",
        itemContent: Router.shared.splitVC.iconsVC.favoritesButton
      )
      return item
      //            return favoriteItem
    case NSToolbarItem.Identifier.search:
      return Router.shared.splitVC.iconsVC.searchItem
    case NSToolbarItem.Identifier.updgrade:
      return customToolbarItem(
        itemIdentifier: .updgrade,
        label: "Buy Pro",
        paletteLabel: "Upgrade",
        toolTip: "Upgrade to Swimbols Pro",
        itemContent: Router.shared.splitVC.upgradeButton
      )
    case NSToolbarItem.Identifier.moreOptions:
      return customToolbarItem(
        itemIdentifier: .moreOptions,
        label: "More options",
        paletteLabel: "Options",
        toolTip: "More options",
        itemContent: NSHostingView(rootView: SWSettingsView())
      )
    default:
      return nil
    }
  }
  
  var favoriteItem: NSTrackingSeparatorToolbarItem {
    let item = NSTrackingSeparatorToolbarItem(
      identifier: .favorites,
      splitView: Router.shared.splitVC.splitView,
      dividerIndex: 1
    )
    //        let button = NSButton(image: NSImage(systemSymbolName: "heart.fill", accessibilityDescription: nil)!,
    //                              target: Router.shared.splitVC.iconsVC, action: #selector(Router.shared.splitVC.iconsVC.showFavorites))
    //        button.bezelStyle = .texturedRounded
    //        item.view = button
    //        let menuItem: NSMenuItem = NSMenuItem()
    //        menuItem.submenu = nil
    //        menuItem.title = "label"
    //        item.menuFormRepresentation = menuItem
    return item
  }
  
  /**
   Mostly base on Apple sample code: https://developer.apple.com/documentation/appkit/touch_bar/integrating_a_toolbar_and_touch_bar_into_your_app
   */
  func customToolbarItem(
    itemIdentifier: NSToolbarItem.Identifier,
    label: String,
    paletteLabel: String,
    toolTip: String,
    itemContent: NSView
  ) -> NSToolbarItem? {
      let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
      
      toolbarItem.label = label
      toolbarItem.paletteLabel = paletteLabel
      toolbarItem.toolTip = toolTip
      /* You don't need to set a `target` if you know what you are doing.
       
       In this example, AppDelegate is also the toolbar delegate.
       
       Since AppDelegate is not a responder, implementing an IBAction in the AppDelegate class has no effect. Try using a subclass of NSWindow or NSWindowController to implement your action methods and use them as the toolbar delegate instead.
       
       Ref: https://developer.apple.com/documentation/appkit/nstoolbaritem/1525982-target
       
       From doc:
       
       If target is nil, the toolbar will call action and attempt to invoke the action on the first responder and, failing that, pass the action up the responder chain.
       */
      //        toolbarItem.target = self
      //        toolbarItem.action = #selector(methodName)
      
      toolbarItem.view = itemContent
      
      // We actually need an NSMenuItem here, so we construct one.
      let menuItem: NSMenuItem = NSMenuItem()
      menuItem.submenu = nil
      menuItem.title = label
      toolbarItem.menuFormRepresentation = menuItem
      
      return toolbarItem
    }
}
