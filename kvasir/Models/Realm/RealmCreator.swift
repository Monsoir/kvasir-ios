//
//  RealmAuthor.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmCreator: RealmBasicObject {
    @objc enum Category: Int {
        case author = 1
        case translator = 2
        
        var toHuman: String {
            switch self {
            case .author:
                return "作者"
            case .translator:
                return "译者"
            }
        }
        
        var toMachine: String {
            switch self {
            case .author:
                return "author"
            case .translator:
                return "translator"
            }
        }
    }
    
    @objc dynamic var name = ""
    @objc dynamic var localeName = ""
    @objc dynamic var category = Category.author
    
    let writtenBooks = List<RealmBook>()
    let translatedBooks = List<RealmBook>()
    
    override static func indexedProperties() -> [String] {
        return ["name", "localName"]
    }
}
