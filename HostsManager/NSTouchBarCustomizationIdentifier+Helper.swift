//
//  NSTouchBarCustomizationIdentifier+Helper.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/22.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

extension NSTouchBarCustomizationIdentifier {
    static func create(type: NSResponder.Type) -> NSTouchBarCustomizationIdentifier {
        let str = "\(ProcessInfo.processInfo.processName)-\(String.init(describing: type))-customization"
        return NSTouchBarCustomizationIdentifier.init(str)
    }
}
