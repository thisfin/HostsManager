//
//  Host.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Host1: NSObject, NSCopying {
    var ip: String
    var domain: String
    var selected: Bool = false
    var desc: String?

    init(ip: String, domain: String, selected: Bool = false, desc: String? = nil) {
        self.ip = ip
        self.domain = domain
        self.selected = selected
        if desc != nil {
            self.desc = desc!
        }
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let host: Host1 = Host1(ip: ip, domain: domain, selected: selected, desc: desc)
        return host;
    }
}
