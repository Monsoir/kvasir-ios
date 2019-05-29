//
//  RealmBasicObjectEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmBasicObject {
    var updateAtReadable: String {
        get {
            return updatedAt.string(withFormat: "yyyy-MM-dd")
        }
    }
    
    @objc dynamic func preCreate() {
    }
    
    @objc dynamic func preUpdate() {
        updatedAt = Date()
    }
}

extension RealmBasicObject: Namable {
    @objc class var toHuman: String {
        return "无名氏"
    }
    
    @objc class var toMachine: String {
        return "no-one"
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
