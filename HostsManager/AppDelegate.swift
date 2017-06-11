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
    private var rootStatusItem: NSStatusItem!
    private lazy var settingWindow = SettingWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)
    private lazy var compareWindow = CompareWindow.init(contentRect: NSRect.zero, styleMask: [.closable, .resizable, .miniaturizable, .titled], backing: .buffered, defer: false)

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

        // 文件权限操作
        FilePermissions.sharedInstance.hostsFilePermissionsCheck()

        // 状态栏
        rootStatusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        rootStatusItem.title = ""
        rootStatusItem.image = WYIconfont.imageWithIcon(content: Constants.iconfontRandom, backgroundColor: .clear, iconColor: .black, size: NSMakeSize(20, 20))
        rootStatusItem.menu = StatusMenu()


        HostsFileManager.sharedInstance.checkFile()
//        NSApp.terminate(nil)

//        let a = AuthorizationItem.init(name: <#T##AuthorizationString#>, valueLength: <#T##Int#>, value: <#T##UnsafeMutableRawPointer?#>, flags: <#T##UInt32#>)
//        WYAuthentication.sharedInstance.authenticate(<#T##command: String##String#>)

//        WYHelp.authenticationHostsFile()
//        WYHelp.deauthenticateHostFile()

//        NSLog("\(WYAuthentication.sharedInstance.isAuthenticated("ls /.Spotlight-V100/"))")
//        NSLog("\(WYAuthentication.sharedInstance.authenticate("ls /.Spotlight-V100/"))")
//        WYAuthentication.sharedInstance.deauthenticate()
//        NSLog("\(WYAuthentication.sharedInstance.isAuthenticated("ls /.Spotlight-V100/"))")

        let hostsFileManager = HostsFileManager.sharedInstance

        switch hostsFileManager.checkHostsFile() {
        case .NeverInit:
            // 读取hosts文件写入本地缓存
            let groups = hostsFileManager.readContentFromFile()
            if groups.count == 1 && groups[0].name == nil {
                groups[0].name = "Default"
            }

            let hostDataManager = HostDataManager.sharedInstance
            hostDataManager.groups = groups
            hostDataManager.updateGroupData()
            // 更新 hosts 文件 md5
            PreferenceManager.sharedInstance.lastHostsFileMD5 = hostsFileManager.fileMD5()

            settingWindow.center()
            settingWindow.makeKeyAndOrderFront(self)

            WYHelp.alertInformational(title: "第一次使用初始化", message: "\(Constants.hostsFileURL.path) 文件中的内容已经导入配置, group 为 Default.")
        case .FileChange:
            // 弹出对比页面进行处理
            // hosts为主 走上面的流程
            // 缓存为主 则写入hosts, 记录md5
            compareWindow.closeBlock = {
                HostDataManager.sharedInstance.loadFile()
                self.settingWindow.center()
                self.settingWindow.makeKeyAndOrderFront(self)
                self.compareWindow.orderOut(self)
            }
            compareWindow.center()
            compareWindow.makeKeyAndOrderFront(self)
            WYHelp.alertWarning(title: "文件检查", message: "\(Constants.hostsFileURL.path) 文件版本与程序中保存的不一致(可能是因为通过别的编辑器修改过), 请处理")
        case .FileUnchange:
            HostDataManager.sharedInstance.loadFile()
            settingWindow.center()
            settingWindow.makeKeyAndOrderFront(self)
        }

//        let a = HostsFileManager.sharedInstance.readContentFromFile()
//        NSLog("\(a)")

//        HostDataManager.init().writeToLocalFile()

//        Application.shared().mainMenu = statusMenu
//        Mock.context = context

//
//        compareWindow.closeBlock = {
//            self.settingWindow.center()
//            self.settingWindow.makeKeyAndOrderFront(self)
//            self.compareWindow.orderOut(self)
//        }
//        compareWindow.center()
//        compareWindow.makeKeyAndOrderFront(self)

//        let alert = NSAlert.init()
//        alert.messageText = "提示"
//        alert.informativeText = "点击确认导入已存在的 hosts 文件, 内容保存在 default 组"
//        alert.alertStyle = .informational
//        alert.beginSheetModal(for: NSApp.mainWindow!) { (modalResponse) in
//            ()
//        }

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
