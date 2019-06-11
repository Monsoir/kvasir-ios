//
//  PlainBook.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct PlainBook: Codable {
    var id: String
    var serverId: String
    var createdAt: String
    var updatedAt: String
    
    var isbn13: String
    var isbn10: String
    var name: String
    var localeName: String
    var summary: String
    var publisher: String
    var imageLarge: String
    var imageMedium: String
    
    var authors: [String]
    var translators: [String]
    
    var digestIds: [String]
    
    init(object: RealmBook) {
        self.id = object.id
        self.serverId = object.serverId
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
        
        self.isbn13 = object.isbn13
        self.isbn10 = object.isbn10
        self.name = object.name
        self.localeName = object.localeName
        self.summary = object.summary
        self.publisher = object.publisher
        self.imageLarge = object.imageLarge
        self.imageMedium = object.imageMedium
        
        self.authors = {
            var results = [String]()
            for ele in object.authors {
                results.append(ele.name)
            }
            return results
        }()
        
        self.translators = {
            var results = [String]()
            for ele in object.translators {
                results.append(ele.name)
            }
            return results
        }()
        
        self.digestIds = object.digests.map { $0.id }
    }
    
    struct Collection: Codable {
        var books: [PlainBook]
    }
    
    struct Tiny: Codable {
        var id: String
        var isbn13: String
        var isbn10: String
        var bookName: String
        
        init(object: RealmBook) {
            self.id = object.id
            self.isbn13 = object.isbn13
            self.isbn10 = object.isbn10
            self.bookName = object.name
        }
    }
}

extension PlainBook {
    var realmObject: RealmBook {
        let object = RealmBook()
        object.id = id
        object.serverId = serverId
        object.createdAt = Date(iso8601String: createdAt) ?? Date()
        object.updatedAt = Date(iso8601String: updatedAt) ?? Date()
        
        object.isbn13 = isbn13
        object.isbn10 = isbn10
        object.name = name
        object.localeName = localeName
        object.summary = summary
        object.publisher = publisher
        object.imageLarge = imageLarge
        object.imageMedium = imageMedium
        
        return object
    }
}
