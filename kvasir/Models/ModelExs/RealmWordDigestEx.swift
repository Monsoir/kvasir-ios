//
//  RealmWordDigestEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

private let DigestTitleLength = 60

extension RealmWordDigest {
    var title: String {
        get {
            var temp = content.replacingOccurrences(of: "\n", with: " ")
            let endIndex = temp.index(temp.startIndex, offsetBy: temp.count < DigestTitleLength ? temp.count : DigestTitleLength)
            let range = temp.startIndex ..< endIndex
            temp = String(temp[range])
            return temp.trimmed
        }
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

extension RealmWordDigest {
    override class var toHuman: String {
        return "文字"
    }
    
    override class var toMachine: String {
        return "word"
    }
}
