//
//  HostDataManager.swift
//  HostsManager
//
//  Created by wenyou on 2017/5/2.
//  Copyright © 2017年 wenyou. All rights reserved.
//

import Foundation

class HostDataManager: NSObject, XMLParserDelegate {
    static let sharedInstance = {
        return HostDataManager()
    }()

    override private init() {

        //todo:
        groups = HostsFileManager.sharedInstance.readContentFromFile()

        super.init()
    }

    var groups: [Group]
    var temp: [Group]?

    var lastParseElementName: String?
    var lastParseElementValue: String?

    // 从本地文件中读取数据
    func readFromLocalFile(data: Data) {
        let xmlParser = XMLParser.init(data: data)
        xmlParser.delegate = self
        xmlParser.parse()
    }

    // 将数据写入到本地文件
    func writeToLocalFile() {
        let root = XMLElement.init(name: "root")

        groups.forEach({ (group) in
            let element = XMLElement.init(name: "group")
            element.addChild(XMLElement.init(name: "name", stringValue: group.name))
            element.addChild(XMLElement.init(name: "selected", stringValue: "\(group.selected)"))
            element.addChild(XMLElement.init(name: "content", stringValue: group.content))
            root.addChild(element)
        })

        let document = XMLDocument.init(rootElement: root)
        document.version = "1.0"
        document.characterEncoding = "UTF-8"
        NSLog(document.xmlString)

        readFromLocalFile(data: document.xmlData)
        NSLog("\(String(describing: temp))")
    }

    // 数据更新处理
    func updateGroupData() {

    }

    // 转换成hosts文件内容
    func toHostsFileContent() -> String {
        return ""
    }

    // MARK: - XMLParserDelegate
    func parserDidStartDocument(_ parser: XMLParser) {
        temp = [Group]()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        switch elementName {
        case "group":
            temp?.append(Group.init())
        default:
            ()
        }
        lastParseElementName = elementName
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        switch elementName {
        case "name":
            if elementName == lastParseElementName {
                temp?.last?.name = lastParseElementValue
            }
        case "content":
            if elementName == lastParseElementName {
                temp?.last?.content = lastParseElementValue!
            }
        case "selected":
            if elementName == lastParseElementName {
                temp?.last?.selected = Bool.init(lastParseElementValue!)!
            }
        default:
            ()
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        lastParseElementValue = string
    }
}
