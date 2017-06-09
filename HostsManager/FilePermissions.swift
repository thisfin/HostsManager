//
//  FilePermissions.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/9.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit

class FilePermissions {
    func a () {
        let isWritable = aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_READ_DATA, ACL_WRITE_DATA])

        let alert = NSAlert.init()
        alert.messageText = "提示"
        alert.informativeText = "你" + (isWritable ? "有" : "无") + " /etc/hosts 文件的权限"
        alert.alertStyle = .critical
        alert.addButton(withTitle: "cancel")
        alert.addButton(withTitle: isWritable ? "消权" : "加权")
        let response = alert.runModal()
        switch response {
        case NSAlertSecondButtonReturn:
            var error: NSDictionary?
            let ope = isWritable ? "-" : "+"
            var cmd = ""
            cmd += "tell application \"Terminal\"\n"
            cmd += "activate (do script \"sudo /bin/chmod \(ope)a \\\"user:\(NSUserName()):allow read,write\\\" /etc/hosts\")\n"
            cmd += "end tell"
            let appleScript = NSAppleScript.init(source: cmd)
            appleScript?.executeAndReturnError(&error)
            NSLog("\(String(describing: error))")
        default:
            ()
        }
    }



    func hostsFilePermissionsCheck() {
        let aclHelp = ACLHelp.init(url: HostsFileManager.sharedInstance.url)

        if aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_READ_DATA, ACL_WRITE_DATA]) {
            return
        }

        switch ({
            let alert = NSAlert.init()
            alert.alertStyle = .critical



            alert.addButton(withTitle: "退出程序")
            alert.addButton(withTitle: "修改权限")
            return alert.runModal()
            }()) {
        case NSAlertFirstButtonReturn:
            var error: NSDictionary?
            var cmd = "tell application \"Terminal\"\n"
            cmd += "activate (do script \"sudo /bin/chmod +a \\\"user:\(NSUserName()):allow read,write\\\" /etc/hosts\")\n"
            cmd += "end tell"
            let appleScript = NSAppleScript.init(source: cmd)
            appleScript.executeAndReturnError(&error)
        default:
            ()
        }
    }
}
