//
//  EditorViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import SnapKit

class EditorViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    private static let leftSideWidth: CGFloat = 200     // 左边列表宽度
    private static let marginWidth: CGFloat = 20        // 边距
    private static let toolViewHeight: CGFloat = 25     // 工具条高度
    private static let cellHeight: CGFloat = 40

    private let tableViewDragTypeName = "DragTypeName"
    private let dataManager = HostDataManager.sharedInstance

    private var tableView: NSTableView!
    private var scrollView: NSScrollView!
//    private var hostView: HostScrollView!
    private var groupEditView: GroupEditView!
    private var toolView: GroupToolView!

    override func loadView() { // 代码实现请务必重载此方法添加view
        view = NSView.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.preferredContentSize = AppDelegate.windowSize

        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.colorWithHexValue(0xececec).cgColor
        view.frame = NSRect(origin: NSPoint.zero, size: AppDelegate.windowSize)

        toolView = GroupToolView(frame: NSRect.zero)
        view.addSubview(toolView)
        toolView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(EditorViewController.marginWidth)
            make.height.equalTo(EditorViewController.toolViewHeight)
            make.bottom.equalToSuperview().offset(0 - EditorViewController.marginWidth)
            make.width.equalTo(EditorViewController.leftSideWidth)
        }
        toolView.addGroupBlock = {
            self.dataManager.groups.append({
                let group = Group.init()
                group.name = "new Group"
                return group
                }())
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(IndexSet(integer: self.dataManager.groups.count - 1), byExtendingSelection: false)
            self.tableView.scrollRowToVisible(self.dataManager.groups.count - 1)
        }
        toolView.removeGroupBlock = {
            let selectedRow = self.tableView.selectedRow
            if selectedRow >= 0 && selectedRow < self.dataManager.groups.count {
                self.dataManager.groups.remove(at: selectedRow)
                self.tableView.reloadData()
            }
        }

//        let segment = NSSegmentedControl()
//        let segment = NSSegmentedControl.init(frame: NSMakeRect(EditorViewController.marginWidth,
//                                                                EditorViewController.marginWidth,
//                                                                EditorViewController.leftSideWidth,
//                                                                EditorViewController.toolViewHeight))
//        segment.segmentStyle = .smallSquare
//        segment.trackingMode = .momentaryAccelerator
//        segment.segmentCount = 3
//        segment.setImage(NSImage(named: NSImageNameAddTemplate), forSegment: 0)
//        segment.setImageScaling(.scaleNone, forSegment: 0)
//        segment.setImage(NSImage(named: NSImageNameRemoveTemplate), forSegment: 0)
//        segment.setImageScaling(.scaleNone, forSegment: 0)
//        segment.setWidth(0, forSegment: 2)
//        view.addSubview(segment)
//
//        segment.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(EditorViewController.marginWidth)
//            //            make.top.equalTo(scrollView.snp_bottomMargin)
//            make.height.equalTo(EditorViewController.toolViewHeight)
//            make.bottom.equalToSuperview().offset(0 - EditorViewController.marginWidth)
//            make.width.equalTo(EditorViewController.leftSideWidth)
//        }

        scrollView = ScrollView()
        scrollView.hasVerticalScroller = true
//        scrollView.borderType = .lineBorder
        scrollView.wantsLayer = true
        scrollView.layer?.masksToBounds = true
        scrollView.layer?.borderWidth = 1
        scrollView.layer?.borderColor = Constants.colorTableBorder.cgColor
        view.addSubview(scrollView)

        scrollView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(EditorViewController.marginWidth)
            make.bottom.equalTo(toolView.snp.top)
            make.left.equalTo(toolView)
            make.width.equalTo(toolView)
        }





//        let addButton = NSButton.init(frame: NSMakeRect(EditorViewController.marginWidth,
//                                                        EditorViewController.marginWidth - 1,
//                                                        EditorViewController.leftSideWidth,
//                                                        EditorViewController.toolViewHeight + 2))
//        addButton.title = "+"
//        //        addButton.font = WYIconfont.fontOfSize(14)
//        addButton.font = NSFont.systemFont(ofSize: 16)
//        addButton.alignment = .center
//        view.addSubview(addButton)

        //        addButton.layer?.borderWidth = 1
        //        addButton.layer?.borderColor = Constants.colorTableBorder.cgColor
        //        addButton.wantsLayer = false
        //        addButton.layer?.backgroundColor = NSColor.blue.cgColor
//        addButton.setButtonType(.momentaryPushIn)
//        addButton.bezelStyle = .smallSquare

        tableView = NSTableView(frame: NSRect(origin: NSPoint.zero, size: scrollView.frame.size))
        tableView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Constants.colorTableBackground
        tableView.headerView = nil
        tableView.register(forDraggedTypes: [tableViewDragTypeName])
        tableView.doubleAction = #selector(EditorViewController.doubleClicked(_:)) // 双击

//        tableView.allowsEmptySelection = false

        let column = NSTableColumn(identifier: "column")
        column.width = tableView.frame.width
        column.resizingMask = .autoresizingMask
        tableView.addTableColumn(column)
        scrollView.contentView.documentView = tableView

//        hostView = HostScrollView()
//        view.addSubview(hostView)
//        hostView.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(EditorViewController.marginWidth)
//            make.bottom.equalToSuperview().offset(0 - EditorViewController.marginWidth)
//            make.left.equalTo(scrollView.snp.right).offset(EditorViewController.marginWidth)
//            make.right.equalToSuperview().offset(0 - EditorViewController.marginWidth)
//        }

        groupEditView = GroupEditView()
        view.addSubview(groupEditView)
        groupEditView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(EditorViewController.marginWidth)
            make.bottom.equalToSuperview().offset(0 - EditorViewController.marginWidth)
            make.left.equalTo(scrollView.snp.right).offset(EditorViewController.marginWidth)
            make.right.equalToSuperview().offset(0 - EditorViewController.marginWidth)
        }

//        groupEditView.setText(text: nil)
        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }

    // MARK: - NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return dataManager.groups.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return dataManager.groups[row]
    }

    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation { // 拖拽
        return .every
    }

    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([tableViewDragTypeName], owner: self)
        pboard.setData(data, forType: tableViewDragTypeName)
        return true
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let pboard = info.draggingPasteboard()
        let rowData = pboard.data(forType: tableViewDragTypeName)
        let rowIndexs: NSIndexSet = NSKeyedUnarchiver.unarchiveObject(with: rowData!) as! NSIndexSet
        let dragRow = rowIndexs.firstIndex

        if dataManager.groups.count > 1 && dragRow != row { // 数据重新排列
            dataManager.groups.insert(dataManager.groups[dragRow], at: row)
            dataManager.groups.remove(at: dragRow + (dragRow > row ? 1 : 0))
            tableView.noteNumberOfRowsChanged()
            tableView.reloadData()
        }
        groupEditView.setText(text: nil) // 此处会 deselect, 事件别的地方无法捕获
        return true
    }

    // MARK: - NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let subView = NSView(frame: NSMakeRect(0, 0, (tableColumn?.width)!, 40))
        subView.addSubview({
            let textField = NSTextField(frame: NSMakeRect(50, (subView.frame.height - 20) / 2, subView.frame.width - 20, 20))
            textField.font = NSFont.systemFont(ofSize: 16)
            textField.textColor = NSColor.black
            textField.stringValue = dataManager.groups[row].name!
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
        return EditorViewController.cellHeight
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row >= 0 && row < dataManager.groups.count {
            let content = dataManager.groups[row].content
            groupEditView.setText(text: content)
        } else {
            groupEditView.setText(text: nil)
        }
    }

    // MARK: - private
    func doubleClicked(_ sender: NSTableView) {
        let row: Int = sender.clickedRow
        NSLog("%ld", row)
    }
}
