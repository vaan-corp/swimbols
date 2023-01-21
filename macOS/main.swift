//
//  main.swift
//  Template
//
//  Created by Imthathullah on 20/01/23.
//  Copyright © 2023 SkyDevz. All rights reserved.
//

import AppKit

// Reference - https://sarunw.com/posts/how-to-create-macos-app-without-storyboard/

// The order we call NSApplication.shared and AppDelegate does matter here.
// If your AppDelegate references something from NSApplication, make sure
// you don't change the order of NSApplication.shared and AppDelegate().
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate

// This line replaces the @main call in AppDelegate created by a new Xcode project
// Reference - https://docs.swift.org/swift-book/ReferenceManual/Attributes.html#ID589
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
