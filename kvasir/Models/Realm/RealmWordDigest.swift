//
//  RealmWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

protocol IWordDigest: IBaicObject {
    var content: String { get set }
    var pageIndex: Int { get set }
}

class RealmWordDigest: RealmBasicObject, IWordDigest {
    @objc dynamic var content = ""
    @objc dynamic var pageIndex = -1
    
    @objc dynamic var book: RealmBook?
    
    override static func indexedProperties() -> [String] {
        return ["content"]
    }
}
