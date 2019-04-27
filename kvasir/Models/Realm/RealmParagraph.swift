//
//  RealmParagraph.swift
//  kvasir
//
//  Created by Monsoir on 4/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmParagraph: RealmWordDigest {
    override class func toHuman() -> String {
        return "段落"
    }
    
    override class func toMachine() -> String {
        return "paragraph"
    }
}
