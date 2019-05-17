//
//  RealmTranslator.swift
//  kvasir
//
//  Created by Monsoir on 4/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmTranslator: RealmCreator {
    let books = List<RealmBook>()
    
    override class func toHuman() -> String {
        return "译者"
    }
    
    class func createAnUnmanagedOneFromPayload(_ payload: [String: Any]) -> RealmCreator {
        return super.createAnUnmanagedOneFromPayload(payload)
    }
}
