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
    
    let books = LinkingObjects(fromType: RealmBook.self, property: "tags")
    let sentences = LinkingObjects(fromType: RealmSentence.self, property: "tags")
    let paragraphs = LinkingObjects(fromType: RealmParagraph.self, property: "tags")
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}
