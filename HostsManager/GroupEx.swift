//
//  GroupEx.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/28.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation
import CoreData

extension Group: ManagedObjectType {
    public static var entityName: String {
        return "Group"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "sequence", ascending: false)]
    }
}
