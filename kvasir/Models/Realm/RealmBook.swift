//
//  RealmBook.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmBook: RealmBasicObject {
    @objc dynamic var isbn = ""
    @objc dynamic var name = ""
    @objc dynamic var localeName = ""
    @objc dynamic var publisher = ""
    
    let authors = LinkingObjects(fromType: RealmAuthor.self, property: "books")
    let translators = LinkingObjects(fromType: RealmTranslator.self, property: "books")
    
    override static func indexedProperties() -> [String] {
        return ["isbn", "name", "localeName"]
    }
    
    override func preSave() {
        super.preSave()
        isbn.trim()
        name.trim()
        localeName.trim()
        publisher.trim()
    }
    
    override func save(completion: @escaping RealmSaveCompletion) {
        preSave()
    }
    
    override func preUpdate() {
        super.preUpdate()
        isbn.trim()
        name.trim()
        localeName.trim()
        publisher.trim()
        updatedAt = Date()
    }
    
    override func update() -> Bool {
        preUpdate()
        do {
            try Realm().write {
                try Realm().add(self, update: true)
            }
            return true
        } catch {
            return false
        }
    }
}
