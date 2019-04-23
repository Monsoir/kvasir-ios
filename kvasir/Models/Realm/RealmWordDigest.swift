//
//  RealmWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmWordDigest: RealmCommonInfo {
    @objc dynamic var content = ""
    
    @objc dynamic var bookName = ""
    let authors = List<String>()
    let translators = List<String>()
    @objc dynamic var publisher = ""
    @objc dynamic var pageIndex = -1
    
    override static func indexedProperties() -> [String] {
        return ["content", "bookName"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    func detach() -> RealmWordDigest {
        return RealmWordDigest(value: self)
    }
}

extension RealmWordDigest: KvasirRealmCRUDable {
    func save() -> Bool {
        self.content.trim()
        self.bookName.trim()
        self.publisher.trim()
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self)
            }
            return true
        } catch {
            return false
        }
    }
    
    func update() -> Bool {
        self.content.trim()
        self.bookName.trim()
        self.publisher.trim()
        do {
            self.updatedAt = Date()
            try Realm().write {
                try Realm().add(self, update: true)
            }
            return true
        } catch {
            return false
        }
    }
    
    func delete() -> Bool {
        do {
            try Realm().write {
                try Realm().delete(self)
            }
            return true
        } catch {
            return false
        }
    }
}

private let DigestTitleLength = 40
extension RealmWordDigest {
    func displayOutline() -> TopListViewModel {
        let title: String = {
            var temp = self.content.replacingOccurrences(of: "\n", with: " ")
            let endIndex = temp.index(temp.startIndex, offsetBy: temp.count < DigestTitleLength ? temp.count : DigestTitleLength)
            let range = temp.startIndex ..< endIndex
            temp = String(temp[range])
            return temp.trimmed
        }()
        let updateAtString = updatedAt.string(withFormat: "yyyy-MM-dd")
        return TopListViewModel(id: id, title: title, bookName: bookName, updatedAt: updateAtString)
    }
}
