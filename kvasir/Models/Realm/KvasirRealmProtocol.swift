//
//  KvasirRealmProtocol.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

typealias RealmSaveCompletion = (_ success: Bool) -> Void

protocol KvasirRealmDetachable : AnyObject {
    func detached() -> Self
}

protocol KvasirRealmCRUDable : class {
    func preSave()
    func save(completion: @escaping RealmSaveCompletion)
    
    func preUpdate()
    func update() -> Bool
    
    func delete() -> Bool
}

protocol KvasirRealmQuerable : class {
//    associatedtype ModelType: RealmCollectionValue
    
    static func allObjects<T: RealmBasicObject>() -> Results<T>?
    static func allObjectsSortedByUpdatedAt<T: RealmBasicObject>() -> Results<T>?
    static func queryObjectWithPrimaryKey<T: RealmBasicObject>(_ key: String) -> T?
}

protocol KvasirRealmReadable {
    static func toHuman() -> String
}
