//
//  NSManagedObjectContextEx.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/23.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func insertObject<A> () -> A where A: NSManagedObject, A: ManagedObjectType {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else {
            fatalError("Wrong object type")
        }
        return obj
    }

    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }

    public func performChanage(block: @escaping () -> ()) {
        perform { 
            block()
            self.saveOrRollback()
        }
    }
}
