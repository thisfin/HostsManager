//
//  NSObjectEx.swift
//  HostsManager
//
//  Created by wenyou on 2017/3/1.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

extension NSObject {
    func allKeys() -> Array<String> {
        var temp: UInt32 = 0
        let count: UnsafeMutablePointer<UInt32> = withUnsafeMutablePointer(to: &temp, {$0})
        let properties: UnsafeMutablePointer<objc_property_t?> = class_copyPropertyList(self.classForCoder, count)
        var propertyArray: [String] = Array()
        for i in 0 ..< Int(count.pointee) {
            let propertyName = property_getName(properties[i])
            propertyArray.append(String.init(cString: propertyName!))
        }
        return propertyArray
    }

    convenience init(properties: Dictionary<String, Any>) {
        self.init()
        self.setValuesForKeys(properties)
    }

    func toDictionary() -> Dictionary<String, Any> {
        return self.dictionaryWithValues(forKeys: self.allKeys())
    }
}
