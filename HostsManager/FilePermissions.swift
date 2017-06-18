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

    func hostsFilePermissionsCheck() {
        let fileManager = FileManager.default
        if fileManager.isReadableFile(atPath: Constants.hostsFileURL.path) && fileManager.isWritableFile(atPath: Constants.hostsFileURL.path) {
            return
        } // 权限校验, 下面的那个 if 已经不需要了, 但是写都写了...

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
