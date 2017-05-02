//
//  Host.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Host: NSObject {
    var ip: String?
    var domain: String?

    func a() {
        let a = self.dictionaryWithValues(forKeys: allKeys())
        NSLog("%@", a)
    }

    convenience init(ip: String, domain: String) {
        self.init()

        self.ip = ip
        self.domain = domain
    }

//    init(ip: String, domain: String, selected: Bool = false, desc: String? = nil) {
//        self.ip = ip
//        self.domain = domain
//        self.selected = selected
//        if desc != nil {
//            self.desc = desc!
//        }
//    }
}
