//
//  PlainCreator.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct PlainCreator: Codable {
    var id: String
    var serverId: String
    var createdAt: String
    var updatedAt: String
    
    var name: String
    var localeName: String
    
    var writtenBooks: [PlainBook.Tiny]
    var translatedBooks: [PlainBook.Tiny]
    
    init(object: RealmCreator) {
        self.id = object.id
        self.serverId = object.serverId
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
        
        self.name = object.name
        self.localeName = object.localeName
        self.writtenBooks = object.writtenBooks.map { PlainBook.Tiny(object: $0) }
        self.translatedBooks = object.translatedBooks.map { PlainBook.Tiny(object: $0) }
    }
    
    struct Collection: Codable {
        var creators: [PlainCreator]
    }
}

extension PlainCreator {
    var realmObject: RealmCreator {
        let object = RealmCreator()
        object.id = id
        object.serverId = serverId
        object.createdAt = Date(iso8601String: createdAt) ?? Date()
        object.updatedAt = Date(iso8601String: updatedAt) ?? Date()
        
        object.name = name
        object.localeName = localeName
        
        return object
    }
}
