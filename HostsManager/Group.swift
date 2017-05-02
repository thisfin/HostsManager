//
//  Group.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Group: NSObject {
    var name: String?
    var content: String?
    var hosts: [Host]?
    var selected: Bool = false

    func a() {
        let a = self.dictionaryWithValues(forKeys: allKeys())
        NSLog("%@", a)
    }
}
