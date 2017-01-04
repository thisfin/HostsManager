//
//  Mock.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation
import CoreData

class Mock {
    static var context: NSManagedObjectContext!

    static let groups: [Group] = {
        var array1: [Group] = []
        for x in 0..<20 {
            array1.append({
                let group = Group(entity: NSEntityDescription.entity(forEntityName: "Group", in: context)!, insertInto: context)
                group.name = String(format: "group name %ld", x)
                group.selected = x % 2 == 0
                group.sequence = Int16(x)
                group.hosts = {
                    var array2: [Host] = []
                    for y in 0..<10 {
                        array2.append({
                            let host = Host(entity: NSEntityDescription.entity(forEntityName: "Host", in: context)!, insertInto: context)
                            host.ip = String(format: "ip %ld %ld", x, y)
                            host.domain = String(format: "domain %ld", y)
                            host.selected = (y + 1) % 2 == 0
                            host.desc = String(format: "desc %ld", y)
                            host.sequence = Int16(y)
                            return host
                            }())
                        //                        array2.append(Host(ip: String(format: "ip %ld %ld", x, y),
                        //                                           domain: String(format: "domain %ld", y),
                        //                                           selected: (y + 1) % 2 == 0,
                        //                                           desc: String(format: "desc %ld", y)))}
                        //                    return array2
                    }
                    return NSSet(array: array2)
                }()
                return group
                }())
        }
        return array1
    }()
}
