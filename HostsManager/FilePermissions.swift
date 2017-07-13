//
//  FilePermissions.swift
//  HostsManager
//
//  Created by wenyou on 2017/6/9.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import AppKit
import WYKit

typealias URLHandleBlock = (_ url: URL) -> Void

class FilePermissions {
    static let sharedInstance = FilePermissions()

    private init() {
    }

    func hostsFileReadPermissionsCheck() {
        let aclHelp = ACLHelp.init(url: Constants.hostsFileURL)
        if FileManager.default.isReadableFile(atPath: Constants.hostsFileURL.path) || aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_READ_DATA]) {
            return
        }

        let alert = NSAlert().then({ (this) in
            this.alertStyle = .critical
            this.messageText = "您没有 hosts 文件的访问权限, 请设置后运行."
        })
        alert.runModal()
        NSApp.terminate(self)
    }

    func hostFileWritePermissionsCheck() -> Bool {
        let aclHelp = ACLHelp.init(url: Constants.hostsFileURL)
        if FileManager.default.isWritableFile(atPath: Constants.hostsFileURL.path) || aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_WRITE_DATA]) {
            return true
        }

        let command = "sudo /bin/chmod +a 'user:\(NSUserName()) allow write' \(Constants.hostsFileURL.path)"
        let alert = NSAlert().then { (this) in
            this.alertStyle = .critical
            this.messageText = "需要获得 hosts 文件的写权限"
            var text = "为了获得完整功能, 对 hosts 文件进行修改, 需要使用 ACL 增加用户 \(NSUserName()) 对文件增加写权限. 如果不设置的话, 您仍能使用只读操作的相关功能.\n\n"
            text += "命令为: \(command)\n\n"
            text += "点击 [修改权限] 会唤起 Terminal, 命令已经拷贝至剪贴板; 请粘贴命令到 Terminal, 执行并输入密码, 然后点击 [校验].\n"
            this.informativeText = text
            this.addButton(withTitle: "修改权限")
            this.addButton(withTitle: "校验")
            this.addButton(withTitle: "关闭")
        }
        let response = alert.runModal()
        switch response {
        case NSAlertFirstButtonReturn:
            let pasteboard = NSPasteboard.general()
            pasteboard.declareTypes([NSStringPboardType], owner: self)
            pasteboard.setString(command, forType: NSPasteboardTypeString)

            NSWorkspace.shared().launchApplication("Terminal")
            return hostFileWritePermissionsCheck()
        case NSAlertSecondButtonReturn:
            return hostFileWritePermissionsCheck()
        default:
            return false
        }
    }

    func hostsFilePermissionsCheck() {
        let fileManager = FileManager.default
        if fileManager.isReadableFile(atPath: Constants.hostsFileURL.path) && fileManager.isWritableFile(atPath: Constants.hostsFileURL.path) {
            return
        }

        let aclHelp = ACLHelp.init(url: Constants.hostsFileURL)
        if aclHelp.checkACLPermission(userName: NSUserName(), perms: [ACL_READ_DATA, ACL_WRITE_DATA]) {
            return
        }

        let command = "sudo /bin/chmod +a \"user:\(NSUserName()):allow read,write\" \(Constants.hostsFileURL.path)"

        let response: NSModalResponse = {
            let alert = NSAlert.init()
            alert.alertStyle = .critical
            alert.messageText = "需要您对 hosts 文件进行权限设置"
            var text = "为了对 hosts 文件进行读写操作, 需要使用 ACL 对文件增加权限.\n\n"
            text += "命令为: \(command)\n\n"
            text += "点击 [修改权限] 会唤起 Terminal, 命令已经拷贝至剪贴板; 请粘贴命令到 Terminal, 执行并输入密码, 然后点击校验.\n"
            alert.informativeText = text
            alert.addButton(withTitle: "修改权限")
            alert.addButton(withTitle: "校验")
            alert.addButton(withTitle: "退出程序")
            return alert.runModal()
        }()

        switch response {
        case NSAlertFirstButtonReturn:
            let pasteboard = NSPasteboard.general()
            pasteboard.declareTypes([NSStringPboardType], owner: self)
            pasteboard.setString(command, forType: NSPasteboardTypeString)

            NSWorkspace.shared().launchApplication("Terminal")
            hostsFilePermissionsCheck()
        case NSAlertSecondButtonReturn:
            hostsFilePermissionsCheck()
        default:
            NSApp.terminate(self)
        }
    }

    // 执行
    func handleFile(bookmarkKey: String, newPath: String, block: URLHandleBlock) {
        var isStale = false
        if let bookmarkData = UserDefaults.standard.object(forKey: bookmarkKey) as? Data,
            let url = try! URL.init(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale), url.path == newPath {
            _ = url.startAccessingSecurityScopedResource()
            block(url)
            url.stopAccessingSecurityScopedResource()
        }
    }

    // 增加书签
    private func addBookmark(url: URL, bookmarkKey: String) {
        let bookmarkData = try! url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        let defaults = UserDefaults.standard
        defaults.set(bookmarkData, forKey: bookmarkKey)
        defaults.synchronize()
    }

    private func isBookmarkExist(bookmarkKey: String) -> Bool {
        return UserDefaults.standard.object(forKey: bookmarkKey) != nil
    }

    func bookmarkCheck() -> Bool{
        if isBookmarkExist(bookmarkKey: Constants.hostsFileBookmarkKey) {
            return true
        }
        let panel = NSOpenPanel().then { (this) in
            this.message = "因为 AppStore 上架限制, 沙盒环境没有直接操作系统文件的权限, 请在下面选择 hosts 文件来获得访问权限."
            this.directoryURL = Constants.hostsFileURL
            this.canChooseDirectories = false
            this.allowedFileTypes = [""]
        }
        switch panel.runModal() {
        case NSFileHandlingPanelOKButton:
            if let url = panel.url, url.path == Constants.hostsFileURL.path {
                addBookmark(url: url, bookmarkKey: Constants.hostsFileBookmarkKey)
            }
            return bookmarkCheck()
        default:
            return false
        }
    }
}
