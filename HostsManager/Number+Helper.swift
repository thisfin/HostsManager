//
//  Int+Helper.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/23.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

extension Int {
    var string: String {
        return "\(self)"
    }
}

extension Float {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat {
    var float: Float {
        return Float.init(self)
    }
}
