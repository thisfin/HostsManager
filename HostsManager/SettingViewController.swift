//
//  SettingViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import ServiceManagement

class SettingViewController: NSViewController {
    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.orange.cgColor
        view.frame = NSRect(origin: NSPoint.zero, size: AppDelegate.windowSize)
    }

    private func startupAppWhenLogin(startup: Bool) {
        let launcherAppIdentifier = "win.sourcecode.HostsManagerHelper"

        _ = SMLoginItemSetEnabled(launcherAppIdentifier as CFString, startup)

        var startedAtLogin = false
        NSWorkspace.shared().runningApplications.forEach { (runningApplication) in
            if let bundleIdentifier = runningApplication.bundleIdentifier, bundleIdentifier == launcherAppIdentifier {
                startedAtLogin = true
                return
            }
        }
        if startedAtLogin {
            DistributedNotificationCenter.default().post(name: NSNotification.Name.init("killhelper"), object: Bundle.main.bundleIdentifier)
        }
    }
}
