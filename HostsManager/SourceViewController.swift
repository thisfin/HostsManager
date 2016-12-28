//
//  SourceViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class SourceViewController: NSViewController {
    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = CGColor.white
        view.frame = CGRect(origin: CGPoint(x: 0, y:0), size: AppDelegate.windowSize)
    }
}
