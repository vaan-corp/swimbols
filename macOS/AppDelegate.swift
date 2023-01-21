//
//  AppDelegate.swift
//  TemplateMac
//
//  Created by Imthathullah on 20/01/23.
//  Copyright © 2023 SkyDevz. All rights reserved.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
  var window: NSWindow!

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
    window = NSWindow(
      contentRect: NSRect(x: 0, y: 0, width: 1600, height: 900),
      styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
      backing: .buffered, defer: false)
    window.isReleasedWhenClosed = false
    window.center()
    window.setFrameAutosaveName("Main Window")

    window.contentViewController = NSHostingController(rootView: ContentView().frame(width: 800, height: 450))
    window.makeKeyAndOrderFront(nil)
    window.setFrame(NSRect(x: 0, y: 0, width: 1600, height: 900), display: true)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

