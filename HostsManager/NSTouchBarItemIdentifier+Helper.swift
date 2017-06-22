//
//  NSTouchBarItemIdentifier+Helper.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/22.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

extension NSTouchBarItemIdentifier {
    static func create(type: NSResponder.Type, suffix: String) -> NSTouchBarItemIdentifier {
        let str = "\(ProcessInfo.processInfo.processName)-\(String.init(describing: type))-item-\(suffix))"
        return NSTouchBarItemIdentifier.init(str)
    }
}
