//
//  DataManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/1/12.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation
import CoreData

class DataManager: NSObject {
    private static let selfInstance = DataManager()

    public static var sharedInstance: DataManager {
        return selfInstance
    }

    override private init() {
        super.init()
    }

    var groups: [Group] = []

    let context: NSManagedObjectContext = { // coredata
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = {
            let bundles = [Bundle(for: AppDelegate.classForCoder())]
            guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
                fatalError("model not found")
            }
            let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
            try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: {
                if let documentURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
                    let infoDictionary = Bundle.main.infoDictionary,
                    let identifier: String = infoDictionary["CFBundleIdentifier"] as? String {
                    var directoryURL = documentURL.appendingPathComponent(identifier).appendingPathComponent("Data")
                    if !FileManager.default.fileExists(atPath: directoryURL.path) {
                        try! FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true)
                    }
                    return directoryURL.appendingPathComponent("model").appendingPathExtension("sqlite")
                }
                return nil
            }(), options: nil)
            return psc
        }()
        return context
    }()
}
