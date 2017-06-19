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
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainAppIdentifier = "win.sourcecode.HostsManager"
        var alreadyRunning = false
        NSWorkspace.shared().runningApplications.forEach { (runningApplication) in
            if let bundleIdentifier = runningApplication.bundleIdentifier, bundleIdentifier == mainAppIdentifier {
                alreadyRunning = true
                return
            }
        }
        if !alreadyRunning {
            DistributedNotificationCenter.default().addObserver(self, selector: #selector(AppDelegate.terminate), name: NSNotification.Name.init("killhelper"), object: mainAppIdentifier)
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
        // Insert code here to tear down your application
    }

    func terminate() {
        NSApp.terminate(nil)
    }
}
