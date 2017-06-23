//
//  WYTableView.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/23.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class WYTableView: NSTableView {
    var rightMouseDownAtRowBlock: ((_ index: Int) -> Void)!

    override func rightMouseDown(with event: NSEvent) {
        let location = convert(event.locationInWindow, to: nil)
        let index = row(at: location)
        if let block = rightMouseDownAtRowBlock {
            block(index)
        }
    }
}
