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
    var statusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        Application.shared().mainMenu = statusMenu

        statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        statusItem.title = ""
        statusItem.image = {
            let image = NSImage(named: "icon.png")
            image?.size = NSSize(width: 20, height: 20)
            return image
        }()
        let statusMenu = NSMenu()
        statusItem.menu = statusMenu

        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "quitt"
        quitMenuItem.action = #selector(AppDelegate.quitClicked(_:))
        statusMenu.addItem(quitMenuItem)






//        let statusItem: NSStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
//        statusItem.title = "hello"
//        statusItem.highlightMode = true
//
//        if let button = statusItem.button {
//            button.title = "hello"
////            button.image = NSImage(named: "StatusBarButtonImage")
////            button.action = Selector("printQuote:")
//        }





        window = NSWindow(contentRect: NSRect(x: 0, y:0, width: 400, height: 400),
                          styleMask: [.closable, .resizable, .miniaturizable, .titled],
                          backing: .buffered,
                          defer: false)
        window.title = "hello"
        window.isOpaque = false
        window.center()
        window.contentViewController = ViewController()
        window.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }
}
