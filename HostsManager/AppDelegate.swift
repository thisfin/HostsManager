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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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


}

