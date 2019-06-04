//
//  PlainTag.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct PlainTag: Codable {
    var id: String
    var serverId: String
    var name: String
    var color: String
    var createdAt: String
    var updatedAt: String
    
    init(object: RealmTag) {
        self.id = object.id
        self.serverId = object.serverId
        self.name = object.name
        self.color = object.color
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
    }
    
    struct Collection: Codable {
        var tags: [PlainTag]
    }
    
    struct Tiny: Codable {
        var id: String
        var name: String
        var color: String
        
        init(object: RealmTag) {
            self.id = object.id
            self.name = object.name
            self.color = object.color
        }
        
        struct Collection: Codable {
            var tags: [PlainTag.Tiny]
        }
    }
}
