//
//  RealmTranslatorEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmTranslator {
    class func createAnUnmanagedOneFromPayload(_ payload: [String: Any]) -> RealmCreator {
        return super.createAnUnmanagedOneFromPayload(payload)
    }
}

extension RealmTranslator {
    override class var toHuman: String {
        return "译者"
    }
    
    override class var toMachine: String {
        return "translator"
    }
}
