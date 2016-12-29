//
//  HostScrollView.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/29.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class HostScrollView: NSScrollView, NSTableViewDataSource, NSTableViewDelegate {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        
    }
}
