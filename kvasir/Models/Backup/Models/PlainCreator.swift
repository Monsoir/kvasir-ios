//
//  PlainCreator.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct PlainCreator<Creator: RealmCreator>: Codable {
    var id: String
    var serverId: String
    var createdAt: String
    var updatedAt: String
    
    var name: String
    var localeName: String
    
    init(object: Creator) {
        self.id = object.id
        self.serverId = object.serverId
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
        
        self.name = object.name
        self.localeName = object.localeName
    }
    
    struct Collection {
        struct Authors: Codable {
            var authors: [PlainCreator<RealmAuthor>]
        }
        struct Translators: Codable {
            var translators: [PlainCreator<RealmTranslator>]
        }
    }
}
