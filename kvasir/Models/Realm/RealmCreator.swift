//
//  RealmAuthor.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmCreator: RealmBasicObject, KvasirRealmReadable {
    @objc dynamic var name = ""
    @objc dynamic var localeName = ""
    
    override static func indexedProperties() -> [String] {
        return ["name", "localName"]
    }
    
    override func preSave() {
        super.preSave()
        name.trim()
        localeName.trim()
    }
    
    override func save(completion: @escaping RealmSaveCompletion) {
        preSave()
        DispatchQueue.global(qos: .userInitiated).async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(self)
                    }
                    completion(true)
                } catch {
                    completion(false)
                }
            })
        }
    }
    
    override func preUpdate() {
        super.preUpdate()
        name.trim()
        localeName.trim()
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
    
    class func toHuman() -> String {
        return "创意者"
    }
}
