//
//  FilePermissions.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/9.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class FilePermissions {
    static let sharedInstance = FilePermissions()

    private init() {
    }

    func bookmarkCheck() {
        NSLog("\(Constants.hostsFileURL.startAccessingSecurityScopedResource())")
        _ = bookmarksCheck()
//        UserDefaults.standard.removeObject(forKey: Constants.userDefaultsHostsBookmarkKey)

        var isStale: Bool = false
        if let bookmarkData = UserDefaults.standard.object(forKey: Constants.userDefaultsHostsBookmarkKey),
            bookmarkData is Data,
            let url = try! URL.init(resolvingBookmarkData: bookmarkData as! Data, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale) {
                NSLog("\(url.startAccessingSecurityScopedResource())")
                url.stopAccessingSecurityScopedResource()
            NSLog("\(url.startAccessingSecurityScopedResource())")
            url.stopAccessingSecurityScopedResource()
        }
    }

    

    func bookmarksCheck() -> Bool {
        let panel = NSOpenPanel()
        panel.directoryURL = Constants.hostsFileURL
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        panel.allowedFileTypes = []
        panel.nameFieldLabel = "title"
        panel.message = "select file"

        var result = false
        switch panel.runModal() {
        case NSFileHandlingPanelOKButton:
            if let url = panel.url, url == Constants.hostsFileURL {
                NSLog("\(Constants.hostsFileURL.path)")

                let bookmarkData = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                UserDefaults.standard.set(bookmarkData, forKey: Constants.userDefaultsHostsBookmarkKey)
                result = true
            }
        case NSFileHandlingPanelCancelButton:
            NSApp.terminate(self)
        default:
            ()
        }
        return result
    }

    func hostsFilePermissionsCheck() {
        let aclHelp = ACLHelp.init(url: Constants.hostsFileURL)

        if aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_READ_DATA, ACL_WRITE_DATA]) {
            return
        }

        let response: NSModalResponse = {
            let alert = NSAlert.init()
            alert.alertStyle = .critical
            alert.messageText = "需要您对 hosts 文件进行权限设置"
            var text = "为了对 hosts 文件进行读写操作, 需要使用 ACL 对文件增加权限.\n\n"
            text += "命令为: sudo /bin/chmod +a \"user:\(NSUserName()):allow read,write\" \(Constants.hostsFileURL.path)\n\n"
            text += "点击 [修改权限] 会唤起 Terminal 执行命令, 请按照提示输入密码, 然后重新启动程序.\n"
            alert.informativeText = text
            alert.addButton(withTitle: "修改权限")
            alert.addButton(withTitle: "退出程序")
            return alert.runModal()
        }()

        switch response {
        case NSAlertFirstButtonReturn:
            var error: NSDictionary?
            var cmd = "tell application \"Terminal\"\n"
            cmd += "activate (do script \"sudo /bin/chmod +a \\\"user:\(NSUserName()):allow read,write\\\" \(Constants.hostsFileURL.path)\")\n"
            cmd += "end tell"
            let appleScript = NSAppleScript.init(source: cmd)
            appleScript?.executeAndReturnError(&error)
        default:
            ()
        }
        NSApp.terminate(self)
    }
}
