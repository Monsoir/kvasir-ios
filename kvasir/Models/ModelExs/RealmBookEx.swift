//
//  RealmBookEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmBook {
    override func preUpdate() {
        super.preUpdate()
        name.trim()
        localeName.trim()
        isbn13.trim()
        isbn10.trim()
        publisher.trim()
        summary.trim()
    }
    
    override func preCreate() {
        super.preCreate()
        name.trim()
        localeName.trim()
        isbn13.trim()
        isbn10.trim()
        publisher.trim()
        summary.trim()
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
}

extension RealmBook {
    override class var toHuman: String {
        return "书籍"
    }
    
    override class var toMachine: String {
        return "book"
    }
}

extension RealmBook: RealmDataBackupable {
    static var backupPath: URL? {
        return SystemDirectories.tmp.url?.appendingPathComponent("books.json")
    }
    
    static func createBackupOperation() -> BackupOperation? {
        guard let backupPath = self.backupPath else { return nil }
        return RealmBookBackupOperation(path: backupPath)
    }
}
