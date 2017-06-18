//
//  Group.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Group: NSObject {
    var name: String?
    var content: String = ""
    var selected: Bool = true
    var hosts: [Host] {
        get {
            let hosts = [Host]()

            let regex = try! NSRegularExpression.init(pattern: "^[^#]*", options: [.anchorsMatchLines])
            let lineRegex = try! NSRegularExpression.init(pattern: "\\s+", options: [.anchorsMatchLines])

            NSLog("\(content)")
            regex.enumerateMatches(in: content, options: [], range: NSRange.init(location: 0, length: content.characters.count)) { (textCheckingResult, matchingFlags, b) in
                if let range = textCheckingResult?.range {
                    var s = (content as NSString).substring(with: range)
                    s = s.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    let textCheckingResults = lineRegex.matches(in: s as String, options: [], range: NSRange.init(location: 0, length: s.characters.count))
                    NSLog("\(textCheckingResults.count)")


                }
            }

            // TODO: 根据content的内容做解析
            return hosts
        }
    }

    func a() {
        let a = self.dictionaryWithValues(forKeys: allKeys())
        NSLog("%@", a)
    }
}
