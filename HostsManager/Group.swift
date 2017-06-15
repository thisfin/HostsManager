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
    var content: String = ""
    var selected: Bool = true
    var hosts: [Host] {
        get {
            // TODO: 根据content的内容做解析
            return [Host]()
        }
    }

    func a() {
        let a = self.dictionaryWithValues(forKeys: allKeys())
        NSLog("%@", a)
    }
}
