//
//  Application.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/24.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit

class Application: NSApplication { // 注册到info.plist
    private let appDelegate: NSApplicationDelegate

    override init() {
        appDelegate = AppDelegate()
        super.init()

        self.delegate = appDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
