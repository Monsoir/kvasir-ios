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
    
    var updateAtReadable: String {
        get {
            return updatedAt.string(withFormat: "yyyy-MM-dd")
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
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
