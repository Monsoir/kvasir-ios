//
//  RealmSentence.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmSentence: RealmWordDigest, Namable {
    override static func toHuman() -> String {
        return "句摘"
    }
    
    override static func toMachine() -> String {
        return "sentence"
    }
}
