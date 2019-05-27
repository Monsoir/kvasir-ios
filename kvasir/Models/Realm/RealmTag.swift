//
//  RealmTag.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmTag: RealmBasicObject {
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    
    let books = List<RealmBook>()
    let sentences = List<RealmSentence>()
    let paragraphs = List<RealmParagraph>()
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    class func toHuman() -> String {
        return "标签"
    }
    
    class func toMachine() -> String {
        return "tag"
    }
}
