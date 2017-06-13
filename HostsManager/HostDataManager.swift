//
//  HostDataManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/2.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class HostDataManager: NSObject, XMLParserDelegate {
    static let sharedInstance = HostDataManager()

    override private init() {
        temp = [Group]()
        groups = temp
        super.init()

        loadFile()
    }

    var groups: [Group]
    private var temp: [Group] // 解析时缓存用
    private var lastParseElementName: String?
    private var lastParseElementValue: String?
    private let fileURL = URL(fileURLWithPath: "\(PreferenceManager.sharedInstance.preferencesDirectoryPath)/hosts.xml") // 文件 path

    // MARK: - unprivate func
    // 读取数据
    func loadFile() {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try! Data(contentsOf: fileURL)
            readFromLocalFile(data: data)
        }
    }

    // 数据更新处理
    func updateGroupData() {
        writeToLocalFile()
    }

    // 转换成hosts文件内容
    func toCompareContent() -> String {
        var result = String.init()
        groups.forEach { (group) in
            result.append("\(Constants.hostsFileGroupPrefix)\(group.name!)\n")
            var content = group.content
            if !group.selected { // 未生效加注释
                content = content.replacingOccurrences(of: "\n", with: "\n# ")
                content = "#\(content)"
            }
            result.append("\(content)\n\n")
        }
        return result
    }

    // MARK: - private func
    // 从本地文件中读取数据
    private func readFromLocalFile(data: Data) {
        let xmlParser = XMLParser.init(data: data)
        xmlParser.delegate = self
        xmlParser.parse()
    }

    // 将数据写入到本地文件
    private func writeToLocalFile() {
        let root = XMLElement.init(name: "root")

        groups.forEach({ (group) in
            let element = XMLElement.init(name: "group")
            element.addChild(XMLElement.init(name: "name", stringValue: group.name))
            element.addChild(XMLElement.init(name: "content", stringValue: group.content))
            if !group.selected { // 默认true
                element.addChild(XMLElement.init(name: "selected", stringValue: "\(group.selected)"))
            }
            root.addChild(element)
        })

        let document = XMLDocument.init(rootElement: root)
        document.version = "1.0"
        document.characterEncoding = "UTF-8"
        NSLog(document.xmlString)

        try! document.xmlData.write(to: fileURL)
    }

    // MARK: - XMLParserDelegate
    func parserDidStartDocument(_ parser: XMLParser) {
        temp.removeAll()
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        groups = temp
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "group":
            temp.append(Group.init())
        default:
            ()
        }
        lastParseElementName = elementName
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let value = lastParseElementValue, elementName == lastParseElementName {
            switch elementName {
            case "name":
                temp.last?.name = value
            case "content":
                temp.last?.content = value
            case "selected":
                temp.last?.selected = Bool.init(value)!
            default:
                ()
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        lastParseElementValue = string
    }
}
