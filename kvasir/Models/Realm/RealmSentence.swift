//
//  RealmSentence.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmSentence: RealmWordDigest {
    override func detach() -> RealmSentence {
        return RealmSentence(value: self)
    }
}

extension RealmSentence: KvasirRealmQuerable {
    typealias ModelType = RealmSentence
    
    static func allObjects() -> Results<RealmSentence>? {
        return try? Realm().objects(RealmSentence.self)
    }
    
    static func allObjectsSortedByUpdatedAt() -> Results<RealmSentence>? {
        return self.allObjects()?.sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    static func queryObjectWithPrimaryKey(_ key: String) -> RealmSentence? {
        do {
            return try Realm().object(ofType: RealmSentence.self, forPrimaryKey: key)
        } catch {
            return nil
        }
    }
}
