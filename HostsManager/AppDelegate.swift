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
    static let windowSize = CGSize(width: 800, height: 500)
    var window: NSWindow!
    var rootStatusItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        Application.shared().mainMenu = statusMenu

        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = WYIconfont.imageWithIcon(content: Constants.iconfontRandom,
                                                        backgroundColor: .clear,
                                                        iconColor: .black,
                                                        size: CGSize(width: 20, height:20))
        rootStatusItem.menu = StatusMenu()

        window = SettingWindow(contentRect: CGRect.zero,
                               styleMask: [.closable, .resizable, .miniaturizable, .titled],
                               backing: .buffered,
                               defer: false)
        window.center()
        window.makeKeyAndOrderFront(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
