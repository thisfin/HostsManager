//
//  Host.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Host: NSObject {
    var ip: String
    var domain: String

    override init() {
        ip = ""
        domain = ""

        super.init()
    }

    convenience init(ip: String, domain: String) {
        self.init()

        self.ip = ip
        self.domain = domain
    }

    func a() {
        let a = self.dictionaryWithValues(forKeys: allKeys())
        NSLog("%@", a)
    }
}
