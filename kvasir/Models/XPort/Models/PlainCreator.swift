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
    
    var books: [PlainBook.Tiny]
    
    init(object: Creator) {
        self.id = object.id
        self.serverId = object.serverId
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
        
        self.name = object.name
        self.localeName = object.localeName
        
        switch object {
        case is RealmAuthor:
            self.books = (object as! RealmAuthor).books.map { PlainBook.Tiny(object: $0) }
        case is RealmTranslator:
            self.books = (object as! RealmTranslator).books.map { PlainBook.Tiny(object: $0) }
        default:
            self.books = []
        }
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

extension PlainCreator {
    var realmObject: Creator {
        let object = Creator()
        object.id = id
        object.serverId = serverId
        object.createdAt = Date(iso8601String: createdAt) ?? Date()
        object.updatedAt = Date(iso8601String: updatedAt) ?? Date()
        
        object.name = name
        object.localeName = localeName
        
        return object
    }
}
