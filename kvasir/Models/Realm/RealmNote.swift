//
//  RealmNote.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmNote: RealmCommonInfo {
    @objc dynamic var title = ""
    @objc dynamic var content = ""
    
    override static func indexedProperties() -> [String] {
        return ["title"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmNote {
    override func save() -> Bool {
        title.trim()
        content.trim()
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
            return true
        } catch {
            return false
        }
    }
    
    override func update() -> Bool {
        title.trim()
        content.trim()
        do {
            updatedAt = Date()
            let realm = try Realm()
            try realm.write {
                realm.add(self, update: true)
            }
            return true
        } catch {
            return false
        }
    }
}
