//
//  AppDelegate.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/23.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import CoreData
import WYKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    static let windowSize = NSMakeSize(800, 500)
    var settingWindow: SettingWindow!
    var compareWindow: CompareWindow!
    var rootStatusItem: NSStatusItem!

//    let context: NSManagedObjectContext = { // coredata
//        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        context.persistentStoreCoordinator = {
//
//
//            let bundles = [Bundle(for: AppDelegate.classForCoder())]
//            guard let model = NSManagedObjectModel.mergedModel(from: bundles) else {
//                fatalError("model not found")
//            }
//            let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
//            try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: {
//                if let documentURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first,
//                    let infoDictionary = Bundle.main.infoDictionary,
//                    let identifier: String = infoDictionary["CFBundleIdentifier"] as? String {
//                    var directoryURL = documentURL.appendingPathComponent(identifier).appendingPathComponent("Data")
//                    if !FileManager.default.fileExists(atPath: directoryURL.path) {
//                        try! FileManager.default.createDirectory(atPath: directoryURL.path, withIntermediateDirectories: true)
//                    }
//                    return directoryURL.appendingPathComponent("model").appendingPathExtension("sqlite")
//                }
//                return nil
//            }(), options: nil)
//            return psc
//        }()
//        return context
//    }()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        UserDefaults.standard.set(true, forKey: "NSConstraintBasedLayoutVisualizeMutuallyExclusiveConstraints") // 布局约束冲突

        switch HostsFileManager.sharedInstance.checkHostsFile().rawValue {
        case HostsFileManager.FileState.neverInit.rawValue:
            // 弹出提示对话框
            // 读取hosts文件写入本地缓存
            // 记录hosts的md5
            ()
        case HostsFileManager.FileState.fileChanage.rawValue:
            // 弹出对比页面进行处理
            // hosts为主 走上面的流程
            // 缓存为主 则写入hosts, 记录md5
            ()
        case HostsFileManager.FileState.fileUnchange.rawValue:
            // 正常进入程序
            ()
        default:
            ()
        }

        let a = HostsFileManager.sharedInstance.readContentFromFile()
        NSLog("\(a)")

//        HostDataManager.init().writeToLocalFile()

//        Application.shared().mainMenu = statusMenu
//        Mock.context = context



        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = WYIconfont.imageWithIcon(content: Constants.iconfontRandom,
                                                        backgroundColor: .clear,
                                                        iconColor: .black,
                                                        size: NSMakeSize(20, 20))
        rootStatusItem.menu = StatusMenu()

        settingWindow = SettingWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)
        compareWindow = CompareWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)

        compareWindow.closeBlock = {
            self.settingWindow.center()
            self.settingWindow.makeKeyAndOrderFront(self)
            self.compareWindow.orderOut(self)
        }
        compareWindow.center()
        compareWindow.makeKeyAndOrderFront(self)

        let alert = NSAlert.init()
        alert.messageText = "提示"
        alert.informativeText = "点击确认导入已存在的 hosts 文件, 内容保存在 default 组"
        alert.alertStyle = .informational
        alert.beginSheetModal(for: NSApp.mainWindow!) { (modalResponse) in
            ()
        }

        /*
        guard let user: User = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as? User else {
            fatalError("Wrong object type")
        }
        user.name = "liyi"
        user.id = 5
//        try! context.save()


        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = NSEntityDescription.entity(forEntityName: "User", in: context)
        let sort = NSSortDescriptor.init(key: "id", ascending: true)
        request.sortDescriptors = [sort]
//        let predicate = NSPredicate.init(format: "")
//        request.predicate = predicate
        try! context.fetch(request).forEach { (user) in
            if let u: User = user as? User {
                NSLog("%ld %@ %ld", u.id, u.name ?? "", u.objectID)
            }
        }
 */

//        let fileManager = FileManager.default

//        let str = try! String.init(contentsOfFile: "/etc/hosts", encoding: .utf8)
//        NSLog("\(str)")

        _ = FileManager.default
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
