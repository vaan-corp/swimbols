//
//  AppDelegate.swift
//  TemplateMac
//
//  Created by Imthathullah on 20/01/23.
//  Copyright © 2023 SkyDevz. All rights reserved.
//

import CanvasKit
import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

  var window: NSWindow!


  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Create the SwiftUI view that provides the window contents.
    //        let contentView = ContentView()
    SymbolStore.shared.loadSymbolsFromFile()
    //        ProductState.storedRawValue = 5
    ProductStore.shared.setup()
    SFPreferences.shared.canShowCopiedToast = false
    SFPreferences.shared.isTrial = ProductStore.shared.isTrial
    // Toolbar **needs** a delegate
    setupMenu()
    NSToolbar.taskListToolbar.delegate = self

    // Create the window and set the content view.
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 1600, height: 1600),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.center()
    window.setFrameAutosaveName("Main Window")
    //        window.contentView = viewController.view
    //        if ProductStore.shared.isPurchased {
    //        window.contentViewController = NSHostingController(rootView: FeaturesText(version: .pro))
    window.contentViewController = Router.shared.splitVC
    //        } else {
    //            window.contentViewController = Router.shared.iapHost
    //        }
    window.toolbar = .taskListToolbar
    window.title = "Swimbols"
    window.subtitle = "All"
    window.toolbarStyle = .unified
    //        window.contentView = NSHostingView(rootView: contentView)
    window.makeKeyAndOrderFront(nil)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationWillBecomeActive(_ notification: Notification) {
    ProductState.updateCount()
  }

  func setupMenu() {
    let swimbolMenu = NSMenu()
    swimbolMenu.addItem(withTitle: "Show/Hide Sidebar", action: #selector(Router.shared.splitVC.toggleSidebar), keyEquivalent: "0")
    swimbolMenu.addItem(withTitle: "Show/Hide Favorites",
                        action: #selector(toggleFavorites), keyEquivalent: "h")
    swimbolMenu.addItem(withTitle: "Quit Swimbols",
                        action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    //        let viewMenu = NSMenu(title: "View")
    let editMenu = NSMenu(title: "Edit")
    editMenu.addItem(withTitle: "Copy Code",
                     action: #selector(copyCode), keyEquivalent: "c")
    editMenu.addItem(withTitle: "Find Symbol",
                     action: #selector(startSearch), keyEquivalent: "f")
    //        NSApplication.shared.mainMenu = menu

    let mainMenu = NSMenu()

    let swimbolMenuItem = NSMenuItem()
    mainMenu.addItem(swimbolMenuItem)
    mainMenu.setSubmenu(swimbolMenu, for:swimbolMenuItem)

    let editMenuItem = NSMenuItem()
    mainMenu.addItem(editMenuItem)
    mainMenu.setSubmenu(editMenu, for: editMenuItem)

    let windowsMenu = NSMenu(title: "Window")
    windowsMenu.addItem(withTitle: "Main Window", action: #selector(bringToFront), keyEquivalent: "m")

    let windowsMenuItem = NSMenuItem()
    mainMenu.addItem(windowsMenuItem)
    mainMenu.setSubmenu(windowsMenu, for: windowsMenuItem)

    NSApplication.shared.mainMenu = mainMenu
  }

  @objc func bringToFront() {
    for window in NSApplication.shared.windows {
      window.makeKeyAndOrderFront(nil)
    }
  }

  @objc func copyCode() {
    guard ProductStore.shared.isPurchased else {
//      SFPreferences.shared.showUpgradeScreen = true
      return
    }
    SFPreferences.shared.copyCode()
  }

  @objc func startSearch() {
    Router.shared.splitVC.iconsVC.startSearch()
  }

  @objc func toggleFavorites() {
    "menu item to toggle favorites called".log()
    //        iconsVC.updateFavorites()
  }
}
