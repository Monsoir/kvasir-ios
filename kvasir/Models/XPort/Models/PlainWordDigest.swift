//
//  PlainWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct PlainWordDigest<Digest: RealmWordDigest>: Codable {
    var id: String
    var serverId: String
    var createdAt: String
    var updatedAt: String
    
    var content: String
    var pageIndex: Int
    
    var book: PlainBook.Tiny?
    var tags: [PlainTag.Tiny]
    
    init(object: Digest) {
        self.id = object.id
        self.serverId = object.serverId
        self.createdAt = object.createdAt.iso8601String
        self.updatedAt = object.updatedAt.iso8601String
        
        self.content = object.content
        self.pageIndex = object.pageIndex
        
        if let book = object.book {
            self.book = PlainBook.Tiny(object: book)
        }
        
        switch object {
        case is RealmSentence:
            self.tags = {
                let digest = (object as! RealmSentence)
                return digest.tags.map {
                    return PlainTag.Tiny(object: $0)
                }
            }()
        case is RealmParagraph:
            self.tags = {
                let digest = (object as! RealmParagraph)
                return digest.tags.map {
                    return PlainTag.Tiny(object: $0)
                }
            }()
        default:
            self.tags = []
        }
    }
    
    struct Collection {
        struct Sentences: Codable {
            var sentences: [PlainWordDigest<RealmSentence>]
        }
        struct Paragraphs: Codable {
            var paragraphs: [PlainWordDigest<RealmParagraph>]
        }
    }
}

extension PlainWordDigest {
    var realmObject: Digest {
        let object = Digest()
        object.id = id
        object.serverId = serverId
        object.createdAt = Date(iso8601String: createdAt) ?? Date()
        object.updatedAt = Date(iso8601String: updatedAt) ?? Date()
        
        object.content = content
        object.pageIndex = pageIndex
        
        return object
    }
}
