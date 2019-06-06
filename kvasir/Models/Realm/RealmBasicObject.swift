//
//  RealmCommonInfo.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

protocol IBaicObject {
    var id: String { get set }
    var serverId: String { get set }
    var createdAt: Date { get  set }
    var updatedAt: Date { get set }
}

class RealmBasicObject: Object, IBaicObject {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var serverId  = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
