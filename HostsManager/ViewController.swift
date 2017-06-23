//
//  ViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import WYKit

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor.black
        view.frame = NSRect(origin: NSPoint.zero, size: AppDelegate.windowSize)
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    override func loadView() {
        view = NSView()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
    }
}
