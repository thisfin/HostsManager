//
//  AppDelegate.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!
    var rootStatusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        Application.shared().mainMenu = statusMenu

        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = {
            let image = NSImage(named: "icon.png")
            image?.size = NSSize(width: 20, height: 20)
            return image
        }()
        rootStatusItem.menu = StatusMenu()

        window = SettingWindow()
//        window = SettingWindow(contentRect: NSRect(x: 0, y:0, width: 400, height: 400),
//                               styleMask: [.closable, .resizable, .miniaturizable, .titled],
//                               backing: .buffered,
//                               defer: false)
        window.title = "hello"
        window.center()
        window.contentViewController = ViewController()
//        window.contentView = {
//            let view = NSView(frame: self.window.frame)
//            return view
//        }()
        window.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
