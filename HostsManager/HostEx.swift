//
//  HostEx.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/28.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation
import CoreData

extension Host: ManagedObjectType {
    public static var entityName: String {
        return "Host"
    }

    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "sequence", ascending: false)]
    }
}
