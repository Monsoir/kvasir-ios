//
//  KvasirRealmProtocol.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

enum DigestType {
    case sentence
    case paragraph
}

protocol KvasirRealmCRUDable : class {
    func save() -> Bool
    func update() -> Bool
}

protocol KvasirRealmQuerable : class {
    associatedtype ModelType: RealmCollectionValue
    
    static func allObjects() -> Results<ModelType>?
    static func allObjectsSortedByUpdatedAt() -> Results<ModelType>?
    static func queryObjectWithPrimaryKey(_ key: String) -> ModelType?
}
