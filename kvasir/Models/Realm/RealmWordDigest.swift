//
//  RealmWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmWordDigest: RealmBasicObject {
    @objc dynamic var content = ""
    @objc dynamic var pageIndex = -1
    
    @objc dynamic var book: RealmBook?
    
    override static func indexedProperties() -> [String] {
        return ["content"]
    }
}
