//
//  User.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

extension User: ManagerObjectType {
    public static var entityName: String {
        return "User"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "data", ascending: false)]
    }
}
