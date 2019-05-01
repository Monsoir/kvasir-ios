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
    
    class func toHuman() -> String {
        return "创意者"
    }
}
