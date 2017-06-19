//
//  WYMenu.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

class StatusMenu: NSMenu {
    var testMenuItem: NSMenuItem!

    init() {
        super.init(title: "")

        initSubMenuItem()
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initSubMenuItem() {
        let aboutMenuItem = NSMenuItem()
        aboutMenuItem.title = "About HostsManager"
        addItem(aboutMenuItem)

        let updateMenuItem = NSMenuItem()
        updateMenuItem.title = "Check for Updates..."
        addItem(updateMenuItem)

        addItem(NSMenuItem.separator())

        let preferencesMenuItem = NSMenuItem()
        preferencesMenuItem.title = "Preferences..."
        addItem(preferencesMenuItem)

        addItem(NSMenuItem.separator())

        testMenuItem = NSMenuItem()
        testMenuItem.title = "test"
        testMenuItem.target = self
        testMenuItem.action = #selector(StatusMenu.testClicked(_:))
        addItem(testMenuItem)

        addItem(NSMenuItem.separator())

        HostDataManager.sharedInstance.groups.forEach { (group) in
            ()
        }

        addItem(NSMenuItem.separator())

        let quitMenuItem = NSMenuItem()
        quitMenuItem.title = "Quit HostsManager"
        quitMenuItem.target = self
        quitMenuItem.action = #selector(StatusMenu.quitClicked(_:))
        addItem(quitMenuItem)
    }

    // MARK: - action
    func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared().terminate(self)
    }

    func testClicked(_ sender: NSMenuItem) {
        removeItem(testMenuItem)
    }
}
