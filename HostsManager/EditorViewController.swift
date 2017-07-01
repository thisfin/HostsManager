//
//  EditorViewController.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/26.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import AppKit
import SnapKit
import WYKit

class EditorViewController: NSViewController {
    fileprivate static let leftSideWidth: CGFloat = 200     // 左边列表宽度
    fileprivate static let marginWidth: CGFloat = 20        // 边距
    fileprivate static let toolViewHeight: CGFloat = 25     // 工具条高度
    fileprivate static let cellHeight: CGFloat = 40

    fileprivate let tableViewDragTypeName = "DragTypeName"
    fileprivate let dataManager = HostDataManager.sharedInstance

    fileprivate var tableView: WYTableView!
    private var scrollView: NSScrollView!
    fileprivate var groupEditView: GroupEditView!
    var toolView: GroupToolView!

    override func loadView() { // 代码实现请务必重载此方法添加view
        view = NSView.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true // 不设置的话行号的字体渲染不对, 待排查
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
            let newGroup: Group = {
                let group = Group.init()
                group.name = "new Group"
                group.selected = false
                group.content = {
                    var str = "127.0.0.1 localhost\n"
                    str += "255.255.255.255 broadcasthost\n"
                    str += "::1 localhost\n"
                    return str
                }()
                return group
            }()

            var selectedRow = self.tableView.selectedRow
            if selectedRow >= 0 && selectedRow < self.dataManager.groups.count {
                selectedRow += 1
                self.dataManager.groups.insert(newGroup, at: selectedRow)
            } else {
                self.dataManager.groups.append(newGroup)
                selectedRow = self.dataManager.groups.count - 1
            }
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(IndexSet(integer: selectedRow), byExtendingSelection: false)
            self.tableView.scrollRowToVisible(selectedRow)
        }
        toolView.removeGroupBlock = {
            let selectedRow = self.tableView.selectedRow
            if selectedRow >= 0 && selectedRow < self.dataManager.groups.count {
                self.dataManager.groups.remove(at: selectedRow)
                self.tableView.reloadData()
                self.groupEditView.setText(text: nil)
            }
        }
        toolView.saveBlock = {
            self.dataManager.updateGroupData()
            HostsFileManager.sharedInstance.writeContentToFile(content: self.dataManager.groups)
            AlertPanel.show("hosts 文件已同步")
        }
        toolView.revertBlock = {
            self.dataManager.loadFile()
            self.tableView.reloadData()
            self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
        }
        toolView.exportConfigBlock = {
            let savePanel = NSSavePanel.init()
            savePanel.allowedFileTypes = ["xml"]
            savePanel.nameFieldStringValue = "hosts_config_backup"
            savePanel.showsTagField = false
            savePanel.directoryURL = URL.init(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            savePanel.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                if response == NSFileHandlingPanelOKButton, let url = savePanel.url {
                    self.dataManager.exportXMLData(url: url)
                }
            })
        }
        toolView.importConfigBlock = {
            let openPanel = NSOpenPanel.init()
            openPanel.allowedFileTypes = ["xml"]
            openPanel.directoryURL = URL.init(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
            openPanel.beginSheetModal(for: self.view.window!, completionHandler: { (response) in
                if response == NSFileHandlingPanelOKButton, let url = openPanel.url {
                    self.dataManager.importXMLData(url: url)
                    self.tableView.reloadData()
                    self.tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                }
            })
        }

        scrollView = WYScrollView()
        scrollView.hasVerticalScroller = true
        // scrollView.borderType = .lineBorder
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

        tableView = WYTableView(frame: NSRect(origin: NSPoint.zero, size: scrollView.frame.size))
        tableView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = Constants.colorTableBackground
        tableView.headerView = nil
        tableView.register(forDraggedTypes: [tableViewDragTypeName])
        tableView.doubleAction = #selector(EditorViewController.doubleClicked(_:)) // 双击
        // tableView.allowsEmptySelection = false
        tableView.addTableColumn({
            let column = NSTableColumn(identifier: "icon")
            column.width = EditorViewController.cellHeight
            return column
            }())
        tableView.addTableColumn({
            let column = NSTableColumn(identifier: "name")
            column.width = tableView.frame.width - EditorViewController.cellHeight
            return column
            }())
        tableView.rightMouseDownAtRowBlock = { (index) in
            if index < 0 || index >= self.dataManager.groups.count {
                return
            }
            if let row = self.tableView.rowView(atRow: index, makeIfNecessary: false), let event = NSApp.currentEvent {
                NSMenu.popUpContextMenu({
                    let menu = NSMenu.init()
                    menu.addItem({
                        let menuItem = NSMenuItem(title: "编辑名称", action: #selector(EditorViewController.rightClickedSetGroupName(_:)), keyEquivalent: "")
                        menuItem.target = self
                        menuItem.tag = index
                        return menuItem
                        }())
                    menu.addItem({
                        let menuItem = NSMenuItem(title: self.dataManager.groups[index].selected ? "设为失效" : "设为活动", action: #selector(EditorViewController.rightClickedSetStatus(_:)), keyEquivalent: "")
                        menuItem.target = self
                        menuItem.tag = index
                        return menuItem
                        }())
                    return menu
                }(), with: event, for: row)
            }
        }
        scrollView.contentView.documentView = tableView

        groupEditView = GroupEditView()
        view.addSubview(groupEditView)
        groupEditView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(EditorViewController.marginWidth)
            make.bottom.equalToSuperview().offset(0 - EditorViewController.marginWidth)
            make.left.equalTo(scrollView.snp.right).offset(EditorViewController.marginWidth)
            make.right.equalToSuperview().offset(0 - EditorViewController.marginWidth)
        }

        tableView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
    }

    override func viewWillAppear() {
        super.viewWillAppear()

        NotificationCenter.default.addObserver(forName: .WYStatusMenuUpdateHosts, object: nil, queue: nil) { (notification) in
            self.tableView.reloadData()
            self.groupEditView.setText(text: nil)
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()

        NotificationCenter.default.removeObserver(self, name: .WYStatusMenuUpdateHosts, object: nil)
    }

    // MARK: - private
    func rightClickedSetGroupName(_ sender: NSMenuItem) { // 右键设置名称
        let index = sender.tag
        if let row = self.tableView.rowView(atRow: index, makeIfNecessary: false) , let textField = (row.view(atColumn: 1) as? NSView)?.subviews[0] as? NSTextField {
            if self.tableView.selectedRow != index {
                self.tableView.selectRowIndexes(IndexSet(integer: index), byExtendingSelection: false)
            }
            textField.becomeFirstResponder()
        }
    }

    func doubleClicked(_ sender: NSTableView) { // 双击改变状态
        changeRowStatus(index: sender.clickedRow)
    }

    func rightClickedSetStatus(_ sender: NSMenuItem) { // 右键改变状态
        changeRowStatus(index: sender.tag)
    }

    func changeRowStatus(index: Int) {
        if index >= 0 && index < dataManager.groups.count {
            let group = dataManager.groups[index]
            group.selected = !group.selected
            tableView.reloadData()
        }
    }
}

extension EditorViewController: NSTableViewDataSource {
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
}

extension EditorViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let identifier = tableColumn?.identifier {
            var subView = tableView.make(withIdentifier: identifier, owner: self)
            if subView == nil { // create
                switch identifier {
                case "icon":
                    subView = NSView(frame: NSMakeRect(0, 0, (tableColumn?.width)!, EditorViewController.cellHeight))
                    subView?.addSubview({
                        let textField = NSTextField(frame: (subView?.frame)!)
                        textField.cell = WYVerticalCenterTextFieldCell()
                        textField.font = WYIconfont.fontOfSize(18)
                        textField.stringValue = "\u{f046}"
                        textField.isEditable = false
                        textField.isBordered = false
                        textField.isBezeled = false
                        textField.drawsBackground = false
                        textField.isSelectable = false
                        textField.alignment = .center
                        textField.backgroundColor = NSColor.clear
                        return textField
                        }())
                case "name":
                    subView = NSView(frame: NSMakeRect(0, 0, (tableColumn?.width)!, EditorViewController.cellHeight))
                    subView?.addSubview({
                        let textField = NSTextField(frame: (subView?.frame)!)
                        textField.cell = WYVerticalCenterTextFieldCell()
                        textField.font = NSFont.systemFont(ofSize: 16)
                        textField.textColor = NSColor.black
                        textField.stringValue = dataManager.groups[row].name!
                        textField.isEditable = true
                        textField.isBordered = false
                        textField.isBezeled = false
                        textField.drawsBackground = false
                        textField.isSelectable = true
                        textField.backgroundColor = NSColor.clear
                        textField.delegate = self
                        return textField
                        }())
                default:
                    ()
                }
            }

            if let view = subView, view.subviews.count > 0 {
                switch identifier {
                case "icon":
                    if let textField = view.subviews[0] as? NSTextField {
                        let isSelected = dataManager.groups[row].selected
                        textField.textColor = isSelected ? Constants.colorSelected : .clear
                    }
                    return view
                case "name":
                    if let textField = view.subviews[0] as? NSTextField {
                        let isSelected = dataManager.groups[row].selected
                        textField.textColor = isSelected ? Constants.colorSelected : Constants.colorFont
                        textField.font = isSelected ? NSFont.boldSystemFont(ofSize: 16) : NSFont.systemFont(ofSize: 16)
                        textField.stringValue = dataManager.groups[row].name!
                        textField.tag = row
                    }
                    return view
                default:
                    ()
                }
            }
        }
        return nil
    }

    func tableView(_ tableView: NSTableView, didAdd rowView: NSTableRowView, forRow row: Int) {
        rowView.backgroundColor = row % 2 == 0 ? Constants.colorTableBackgroundLight : Constants.colorTableBackground
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return EditorViewController.cellHeight
    }

    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        if let rowView = tableView.make(withIdentifier: "row", owner: self) as? NSTableRowView {
            return rowView
        }
        let rowView = WYTableRowView.init()
        rowView.identifier = "row"
        return rowView
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        let row = tableView.selectedRow
        if row >= 0 && row < dataManager.groups.count {
            let content = dataManager.groups[row].content
            groupEditView.setText(text: content, index: row)
        } else {
            groupEditView.setText(text: nil)
        }
    }
}

extension EditorViewController: NSTextFieldDelegate {
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if let string = fieldEditor.string {
            let group = dataManager.groups[control.tag]
            group.name = string
        }
        return true
    }
}
