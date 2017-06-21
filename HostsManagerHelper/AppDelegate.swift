//
//  AppDelegate.swift
//  HostsManagerHelper
//
//  Created by wenyou on 2017/6/19.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let mainAppIdentifier = "win.sourcecode.HostsManager"

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var alreadyRunning = false
        NSWorkspace.shared().runningApplications.forEach { (runningApplication) in
            if let bundleIdentifier = runningApplication.bundleIdentifier, bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                return
            }
        }
        if !alreadyRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.terminate), name: .WYKillHelper, object: mainAppIdentifier)
            var components = (Bundle.main.bundlePath as NSString).pathComponents
            components.removeLast()
            components.removeLast()
            components.removeLast()
            components.append("MacOS")
            components.append("HostsManager")
            let path = NSString.path(withComponents: components)
            if FileManager.default.fileExists(atPath: path) {
                NSWorkspace.shared().launchApplication(path)
            }
        } else {
            terminate()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        DistributedNotificationCenter.default().removeObserver(self, name: .WYKillHelper, object: mainAppIdentifier)
    }

    func terminate() {
        NSApp.terminate(nil)
    }
}

extension Notification.Name {
    static let WYKillHelper = Notification.Name("KillHelper")
}
