//
//  PlainWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct PlainWordDigest: Codable {
    var id: String
    var serverId: String
    var createdAt: String
    var updatedAt: String
    
    var content: String
    var pageIndex: Int
    var category: Int
    
    var book: PlainBook.Tiny?
    var tags: [PlainTag.Tiny]
    
    init(object: RealmWordDigest) {
        self.id = object.id
        self.serverId = object.serverId
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
        
        self.content = object.content
        self.pageIndex = object.pageIndex
        
        if let book = object.book {
            self.book = PlainBook.Tiny(object: book)
        }
        
        self.tags = object.tags.map { PlainTag.Tiny(object: $0) }
        self.category = object.category.rawValue
    }
    
    struct Collection: Codable {
        var digests: [PlainWordDigest]
    }
}

extension PlainWordDigest {
    var realmObject: RealmWordDigest {
        let object = RealmWordDigest()
        
        object.id = id
        object.serverId = serverId
        object.createdAt = Date(iso8601String: createdAt) ?? Date()
        object.updatedAt = Date(iso8601String: updatedAt) ?? Date()
        
        object.content = content
        object.pageIndex = pageIndex
        object.category = RealmWordDigest.Category(rawValue: category) ?? .paragraph
        
        return object
    }
}
