//
//  RealmParagraph.swift
//  kvasir
//
//  Created by Monsoir on 4/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmParagraph: RealmWordDigest {
}

extension RealmParagraph: KvasirRealmDetachable {
    func detach() -> RealmParagraph {
        return RealmParagraph(value: self)
    }
}

extension RealmParagraph: KvasirRealmQuerable {
    typealias ModelType = RealmParagraph
    
    static func allObjects() -> Results<RealmParagraph>? {
        return try? Realm().objects(RealmParagraph.self)
    }
    
    static func allObjectsSortedByUpdatedAt() -> Results<RealmParagraph>? {
        return self.allObjects()?.sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    static func queryObjectWithPrimaryKey(_ key: String) -> RealmParagraph? {
        do {
            return try Realm().object(ofType: RealmParagraph.self, forPrimaryKey: key)
        } catch {
            return nil
        }
    }
}
