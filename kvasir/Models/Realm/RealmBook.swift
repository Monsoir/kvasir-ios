//
//  RealmBook.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

protocol IBook: IBaicObject {
    var isbn13: String { get set }
    var isbn10: String { get set }
    var name: String { get set }
    var localeName: String { get set }
    var summary: String { get set }
    var publisher: String { get set }
    var imageLarge: String { get set }
    var imageMedium: String { get set }
}

class RealmBook: RealmBasicObject, IBook {
    @objc dynamic var isbn13 = ""
    @objc dynamic var isbn10 = ""
    @objc dynamic var name = ""
    @objc dynamic var localeName = ""
    @objc dynamic var summary = ""
    @objc dynamic var publisher = ""
    @objc dynamic var imageLarge = ""
    @objc dynamic var imageMedium = ""
    
    let sentences = List<RealmSentence>()
    let paragraphs = List<RealmParagraph>()
    
    let authors = LinkingObjects(fromType: RealmAuthor.self, property: "books")
    let translators = LinkingObjects(fromType: RealmTranslator.self, property: "books")
    
    override static func indexedProperties() -> [String] {
        return ["isbn13", "isbn10", "name", "localeName"]
    }
}
