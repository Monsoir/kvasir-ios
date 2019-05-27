//
//  RealmParagraph.swift
//  kvasir
//
//  Created by Monsoir on 4/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmParagraph: RealmWordDigest, Namable {
    
    let tags = LinkingObjects(fromType: RealmTag.self, property: "paragraphs")
    
    override class func toHuman() -> String {
        return "段摘"
    }
    
    override class func toMachine() -> String {
        return "paragraph"
    }
}
