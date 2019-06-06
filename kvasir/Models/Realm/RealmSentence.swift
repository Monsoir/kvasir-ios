//
//  RealmSentence.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

protocol ISentence: IWordDigest {
}

class RealmSentence: RealmWordDigest, ISentence {
    let tags = LinkingObjects(fromType: RealmTag.self, property: "sentences")
}
