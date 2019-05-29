//
//  RealmCreatorEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmCreator {
    class func createAnUnmanagedOneFromPayload<T: RealmCreator>(_ payload: [String: Any]) -> T {
        let creator = T()
        creator.name = payload["name"] as? String ?? ""
        creator.localeName = payload["localeName"] as? String ?? ""
        return creator
    }
    
    override func preCreate() {
        super.preCreate()
        name.trim()
        localeName.trim()
    }
    
    override func preUpdate() {
        super.preUpdate()
        name.trim()
        localeName.trim()
    }
}

extension RealmCreator {
    override class var toHuman: String {
        return "创意者"
    }
    
    override class var toMachine: String {
        return "creator"
    }
}
