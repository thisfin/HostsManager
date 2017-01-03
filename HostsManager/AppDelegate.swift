//
//  AppDelegate.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa
import CoreData

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static let windowSize = NSMakeSize(800, 500)
    var window: NSWindow!
    var rootStatusItem: NSStatusItem!

    let context: NSManagedObjectContext = { // coredata
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = {
            let bundles = [Bundle(for: AppDelegate.classForCoder())]
            guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
                fatalError("model not found")
            }
            let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
            try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: {
                let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
                let storeURL = documentURL?.appendingPathComponent("model.sqlite")
                return storeURL
            }(), options: nil)
            return psc
        }()
        return context
    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        Application.shared().mainMenu = statusMenu

        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = WYIconfont.imageWithIcon(content: Constants.iconfontRandom,
                                                        backgroundColor: .clear,
                                                        iconColor: .black,
                                                        size: NSMakeSize(20, 20))
        rootStatusItem.menu = StatusMenu()

        window = SettingWindow(contentRect: NSRect.zero,
                               styleMask: [.closable, .resizable, .miniaturizable, .titled],
                               backing: .buffered,
                               defer: false)
        window.center()
        window.makeKeyAndOrderFront(self)

        guard let user: User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User else {
            fatalError("Wrong object type")
        }
        user.name = "liyi"
        user.id = 3
//        try! context.save()


        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let sort = NSSortDescriptor.init(key: "id", ascending: true)
        request.sortDescriptors = [sort]
//        let predicate = NSPredicate.init(format: "")
//        request.predicate = predicate
        try! context.fetch(request).forEach { (user) in
            if let u: User = user as? User {
                NSLog("%ld %@", u.id, u.name ?? "")
            }
        }
//
//
//        // 初始化一个查询请求
//        NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
//        // 设置要查询的实体
//        request.entity = [NSEntityDescription entityForName:@"Person" inManagedObjectContext:context];
//        // 设置排序（按照age降序）
//        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"age" ascending:NO];
//        request.sortDescriptors = [NSArray arrayWithObject:sort];
//        // 设置条件过滤(搜索name中包含字符串"Itcast-1"的记录，注意：设置条件过滤时，数据库SQL语句中的%要用*来代替，所以%Itcast-1%应该写成*Itcast-1*)
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name like %@", @"*Itcast-1*"];
//        request.predicate = predicate;
//        // 执行请求
//        NSError *error = nil;
//        NSArray *objs = [context executeFetchRequest:request error:&error];
//        if (error) {
//            [NSException raise:@"查询错误" format:@"%@", [error localizedDescription]];
//        }  
//        // 遍历数据  
//        for (NSManagedObject *obj in objs) {  
//            NSLog(@"name=%@", [obj valueForKey:@"name"]  
//        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
