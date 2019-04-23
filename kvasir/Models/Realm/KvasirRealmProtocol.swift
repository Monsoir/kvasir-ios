//
//  KvasirRealmProtocol.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

protocol KvasirRealmDetachable : class {
    associatedtype ModelType: RealmCollectionValue
    
    func detach() -> ModelType
}

protocol KvasirRealmCRUDable : class {
    func save() -> Bool
    func update() -> Bool
    func delete() -> Bool
}

protocol KvasirRealmQuerable : class {
    associatedtype ModelType: RealmCollectionValue
    
    static func allObjects() -> Results<ModelType>?
    static func allObjectsSortedByUpdatedAt() -> Results<ModelType>?
    static func queryObjectWithPrimaryKey(_ key: String) -> ModelType?
}

extension Object: KvasirRealmCRUDable {
    @objc func save() -> Bool {
        return false
    }
    
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
