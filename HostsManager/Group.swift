//
//  Group.swift
//  HostsManager
//
//  Created by wenyou on 2016/12/28.
//  Copyright © 2016年 wenyou. All rights reserved.
//

import Foundation

class Group {
    var name: String?
    var content: String = ""
    var selected: Bool = true
    var hosts: [Host] {
        get {
            var hosts = [Host]()
            let regex = try! NSRegularExpression.init(pattern: "^[^#\r\n]*", options: [.anchorsMatchLines])
            let lineRegex = try! NSRegularExpression.init(pattern: "[^\\s]+", options: [.anchorsMatchLines])
            // parse line
            regex.enumerateMatches(in: content, options: [], range: NSRange.init(location: 0, length: content.characters.count)) { (textCheckingResult, matchingFlags, b) in
                if let range = textCheckingResult?.range {
                    var line = (content as NSString).substring(with: range)
                    line = line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    // parse space
                    let textCheckingResults = lineRegex.matches(in: line, options: [], range: NSRange.init(location: 0, length: line.characters.count))
                    if textCheckingResults.count >= 2 {
                        let ip = (line as NSString).substring(with: textCheckingResults[0].range)
                        for i in 1 ..< textCheckingResults.count {
                            let domain = (line as NSString).substring(with: textCheckingResults[i].range)
                            let host = Host(ip: ip, domain: domain)
                            hosts.append(host)
                        }
                    }
                }
            }
            return hosts
        }
    }
}
