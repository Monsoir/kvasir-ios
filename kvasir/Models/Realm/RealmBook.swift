//
//  RealmBook.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmBook: RealmBasicObject {
    @objc dynamic var isbn = ""
    @objc dynamic var name = ""
    @objc dynamic var localeName = ""
    @objc dynamic var publisher = ""
    
    let sentences = List<RealmSentence>()
    let paragraphs = List<RealmParagraph>()
    let authors = LinkingObjects(fromType: RealmAuthor.self, property: "books")
    let translators = LinkingObjects(fromType: RealmTranslator.self, property: "books")
    
    override static func indexedProperties() -> [String] {
        return ["isbn", "name", "localeName"]
    }
    
    override func preSave() {
        super.preSave()
        isbn.trim()
        name.trim()
        localeName.trim()
        publisher.trim()
    }
    
    func save(completion: @escaping RealmSaveCompletion) {
        preSave()
    }
    
    override func preUpdate() {
        super.preUpdate()
        isbn.trim()
        name.trim()
        localeName.trim()
        publisher.trim()
        updatedAt = Date()
    }
    
    private func createListReadable(elements: [String], separator: String) -> String {
        return elements.joined(separator: separator)
    }
    
    func createAuthorsReadable(_ separator: String) -> String {
        return createListReadable(elements: authors.map { $0.name }, separator: separator)
    }
    
    func createTranslatorReadabel(_ separator: String) -> String {
        return createListReadable(elements: translators.map { $0.name }, separator: separator)
    }
}
