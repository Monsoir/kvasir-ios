//
//  RealmCommonInfo.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmBasicObject: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var serverId  = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmBasicObject: KvasirRealmCRUDable {
    @objc func preSave() {}
    
    @objc func save() -> Bool {
        return false
    }
    
    @objc func preUpdate() {}
    
    @objc func update() -> Bool {
        return false
    }
    
    @objc func delete() -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                realm.delete(self)
            }
            return true
        } catch {
            return false
        }
    }
}

extension RealmBasicObject {
    static func allObjects<T: RealmBasicObject>(of type: T.Type) -> Results<T>? {
        return try? Realm().objects(type.self)
    }
    
    static func allObjectsSortedByUpdatedAt<T: RealmBasicObject>(of type: T.Type) -> Results<T>? {
        return self.allObjects(of: type.self)?.sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    static func queryObjectWithPrimaryKey<T: RealmBasicObject>(of type: T.Type, key: String) -> T? {
        return try! Realm().object(ofType: type.self, forPrimaryKey: key)
    }
    
    static func objectsForPrimaryKeys<T: RealmBasicObject>(of type: T.Type, keys: [String]) -> Results<T>? {
        return self.allObjects(of: type.self)?.filter("\(T.primaryKey()!) IN %@", keys)
    }
}

// https://github.com/realm/realm-cocoa/issues/3381#issuecomment-256243390
extension RealmBasicObject: KvasirRealmDetachable {
    func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? KvasirRealmDetachable {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}
