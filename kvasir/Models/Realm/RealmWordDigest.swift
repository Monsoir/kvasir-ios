//
//  RealmWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmWordDigest: RealmBasicObject {
    @objc enum Category: Int {
        case sentence
        case paragraph
        
        var toHuman: String {
            switch self {
            case .sentence:
                return "句摘"
            case .paragraph:
                return "段摘"
            }
        }
        
        var toMachine: String {
            switch self {
            case .sentence:
                return "sentence"
            case .paragraph:
                return "paragraph"
            }
        }
    }
    
    @objc dynamic var content = ""
    @objc dynamic var pageIndex = -1
    @objc dynamic var category = Category.sentence
    
    @objc dynamic var book: RealmBook?
    
    let tags = LinkingObjects(fromType: RealmTag.self, property: "wordDigests")
    
    override static func indexedProperties() -> [String] {
        return ["content"]
    }
}
