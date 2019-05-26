//
//  RealmBook.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmBook: RealmBasicObject {
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

extension RealmBook {
    private func createListReadable(elements: [String], separator: String) -> String {
        return elements.joined(separator: separator)
    }
    
    func createAuthorsReadable(_ separator: String) -> String {
        return createListReadable(elements: authors.map { $0.name }, separator: separator)
    }
    
    func createTranslatorReadabel(_ separator: String) -> String {
        return createListReadable(elements: translators.map { $0.name }, separator: separator)
    }
    
    var hasImage: Bool {
        get {
            return !imageLarge.isEmpty || !imageMedium.isEmpty
        }
    }
    
    var thumbnailImage: String {
        get {
            return imageMedium.isEmpty ? imageLarge : imageMedium
        }
    }
    
    var highQualityImage: String {
        get{
            return imageLarge.isEmpty ? imageMedium : imageLarge
        }
    }
    
    func preCreate() {
        name.trim()
        localeName.trim()
        isbn13.trim()
        isbn10.trim()
        publisher.trim()
        summary.trim()
    }
    
    func preUpdate() {
        name.trim()
        localeName.trim()
        isbn13.trim()
        isbn10.trim()
        publisher.trim()
        updatedAt = Date()
        summary.trim()
    }
}
