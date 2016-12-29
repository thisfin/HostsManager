//
//  HostScrollView.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/29.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Cocoa

class HostScrollView: NSScrollView, NSTableViewDataSource, NSTableViewDelegate {
    var tableView: NSTableView!
    var datas: [Host]!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        hasVerticalScroller = true
        wantsLayer = true
        layer?.masksToBounds = true
        layer?.borderWidth = 1
        layer?.borderColor = Constants.colorTableBorder.cgColor

        tableView = NSTableView(frame: NSMakeRect(0, 0, frameRect.size.width, frameRect.size.height))
        tableView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Constants.colorTableBackground
        contentView.documentView = tableView

        let column = NSTableColumn(identifier: "column")
        column.minWidth = tableView.frame.width
        column.resizingMask = .autoresizingMask
        tableView.addTableColumn(column)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return datas != nil ? datas.count : 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return datas[row]
    }

    // MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let subView = NSView(frame: NSRect(x: 0, y: 0, width: (tableColumn?.width)!, height: 30))
        subView.addSubview({
            let textField = NSTextField(frame: CGRect(x: 50,
                                                      y: (subView.frame.height - 20) / 2,
                                                      width: subView.frame.width - 16,
                                                      height: 16))
            textField.font = NSFont.systemFont(ofSize: 12)
            textField.textColor = NSColor.colorWithHexValue(0x333333)
            textField.stringValue = String(format: "%@ %@ %@", datas[row].ip, datas[row].domain, datas[row].desc ?? "")
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

    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = row % 2 == 0 ? Constants.colorTableBackgroundLight : Constants.colorTableBackground
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }

    // MARK: - private
    func doubleClicked(_ sender: NSTableView) {
        let row: Int = sender.clickedRow
        NSLog("%ld", row)
    }

    func setTableData(_ datas: [Host]) {
        self.datas = datas
        tableView.reloadData()
    }
}
