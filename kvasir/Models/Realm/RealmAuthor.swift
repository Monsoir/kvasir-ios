//
//  RealmAuthor.swift
//  kvasir
//
//  Created by Monsoir on 4/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmAuthor: RealmCreator {
    let books = List<RealmBook>()
}
