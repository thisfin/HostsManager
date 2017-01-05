//
//  Group.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Group1: NSObject, NSCopying {
    var name: String?
    var hostList: [Host1]?
    var selected: Bool = false

    func copy(with zone: NSZone? = nil) -> Any {
        let group: Group1 = Group1()
        group.name = name
        group.hostList = hostList
        group.selected = selected
        return group;
    }
}