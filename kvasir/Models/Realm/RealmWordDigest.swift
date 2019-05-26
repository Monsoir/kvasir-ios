//
//  RealmWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

private let DigestTitleLength = 60

class RealmWordDigest: RealmBasicObject {
    @objc dynamic var content = ""
    @objc dynamic var pageIndex = -1
    
    @objc dynamic var book: RealmBook?
    
    let tags = List<RealmTag>()
    
    var title: String {
        get {
            var temp = content.replacingOccurrences(of: "\n", with: " ")
            let endIndex = temp.index(temp.startIndex, offsetBy: temp.count < DigestTitleLength ? temp.count : DigestTitleLength)
            let range = temp.startIndex ..< endIndex
            temp = String(temp[range])
            return temp.trimmed
        }
    }
    
    override static func indexedProperties() -> [String] {
        return ["content"]
    }
    
    class func toHuman() -> String {
        return "文字"
    }
    
    class func toMachine() -> String {
        return "word"
    }
    
    override func preCreate() {
        super.preCreate()
        content.trim()
    }
    
    override func preUpdate() {
        super.preUpdate()
        content.trim()
    }
}
