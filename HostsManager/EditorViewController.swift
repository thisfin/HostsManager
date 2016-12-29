//
//  EditorViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa
import SnapKit

class EditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    var tableView: NSTableView!

    var scrollView: NSScrollView!
    var hostView: HostScrollView!

    override func loadView() { // 代码实现请务必重载此方法添加view
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredContentSize = AppDelegate.windowSize


        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.colorWithHexValue(0xececec).cgColor
        view.frame = CGRect(origin: CGPoint(x: 0, y:0), size: AppDelegate.windowSize)






        scrollView = ScrollView(frame: CGRect(x: 20, y: 20, width: 200, height: view.frame.height - 20 * 2))
        scrollView.autoresizingMask = [.viewMaxXMargin, .viewHeightSizable]
        scrollView.hasVerticalScroller = true
//        scrollView.borderType = .lineBorder
        scrollView.wantsLayer = true
        scrollView.layer?.masksToBounds = true
        scrollView.layer?.borderWidth = 1
        scrollView.layer?.borderColor = Constants.colorTableBorder.cgColor
        view.addSubview(scrollView)

        tableView = NSTableView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: scrollView.frame.size))
        tableView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Constants.colorTableBackground
        tableView.doubleAction = #selector(EditorViewController.doubleClicked(_:)) // 双击
        scrollView.contentView.documentView = tableView

        let column = NSTableColumn(identifier: "column")
        column.minWidth = tableView.frame.width
        column.resizingMask = .autoresizingMask
        tableView.addTableColumn(column)

        hostView = HostScrollView(frame: NSMakeRect(scrollView.frame.origin.x + scrollView.frame.size.width + 20,
                                                    scrollView.frame.origin.y,
                                                    view.frame.size.width - 20 * 2 - scrollView.frame.origin.x - scrollView.frame.size.width,
                                                    scrollView.frame.size.height))
        view.addSubview(hostView)

        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }

    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Mock.groups.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return Mock.groups[row]
    }

    // MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let subView = NSView(frame: NSRect(x: 0, y: 0, width: (tableColumn?.width)!, height: 40))
        subView.addSubview({
            let textField = NSTextField(frame: CGRect(x: 50,
                                                      y: (subView.frame.height - 20) / 2,
                                                      width: subView.frame.width - 20,
                                                      height: 20))
            textField.font = NSFont.systemFont(ofSize: 16)
            textField.textColor = NSColor.black
            textField.stringValue = Mock.groups[row].name!
            textField.isEditable = true
            textField.isBordered = false
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isSelectable = false

            textField.backgroundColor = NSColor.clear
            return textField
            }())
        return subView
    }

//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//        let rowView = NSTableRowView(frame: NSRect(x: 0, y: 0, width: 150, height: 50))
//        rowView.backgroundColor = NSColor.red// row % 2 == 0 ? NSColor.white : NSColor.colorWithHexValue(0xf5f5f5)
////        rowView.addSubview({
////            let textField = NSTextField(frame: view.frame)
////            textField.textColor = NSColor.black
////            textField.stringValue = Mock.groups[row].name!
////            textField.isEditable = false
////            textField.isBordered = false
////
////            textField.isBezeled = false
////            textField.drawsBackground = false
////            textField.isSelectable = false
////
////            //            textField.backgroundColor = NSColor.clear
////            return textField
////            }())
//        return rowView
//    }

    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = row % 2 == 0 ? Constants.colorTableBackgroundLight : Constants.colorTableBackground
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row: Int = tableView.selectedRow
        hostView.setTableData(Mock.groups[row].hostList!)
    }

    // MARK: - private
    func doubleClicked(_ sender: NSTableView) {
        let row: Int = sender.clickedRow
        NSLog("%ld", row)
    }
}
