//
//  ViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override var representedObject: Any? {
        didSet {
        }
    }

    override func loadView() {
        self.view = {
            let view = NSView(frame: NSRect(x: 0, y: 100, width: 300, height: 300))
            view.wantsLayer = true
            view.layer?.borderWidth = 2
            view.layer?.borderColor = NSColor.red.cgColor
            view.wantsLayer = true
            view.layer?.backgroundColor = CGColor.black
            return view
        }()
    }
}
