//
//  RealmTag.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmTag: RealmBasicObject {
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    
    let wordDigests = List<RealmWordDigest>()
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
}
