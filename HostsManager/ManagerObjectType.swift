//
//  ManagerObjectType.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/3.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation
import CoreData

public protocol ManagerObjectType: class {
    static var entityName:String {get}
    static var defaultSortDescriptors: [NSSortDescriptor] {get}
}

extension ManagerObjectType {
    public static var defaultSortDescriptors: [NSSortDescriptor] {
        return []
    }

    public static var sortFetchRequest: NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
}
