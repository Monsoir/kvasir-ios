//
//  RealmParagraph.swift
//  kvasir
//
//  Created by Monsoir on 4/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

protocol IParagraph: IWordDigest {
    
}

class RealmParagraph: RealmWordDigest, IParagraph {
    let tags = LinkingObjects(fromType: RealmTag.self, property: "paragraphs")
}
