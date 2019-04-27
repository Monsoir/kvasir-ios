//
//  RealmWordDigest.swift
//  kvasir
//
//  Created by Monsoir on 4/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmWordDigest: RealmBasicObject {
    @objc dynamic var content = ""
    @objc dynamic var pageIndex = -1
    
    @objc dynamic var book: RealmBook?
    
    override static func indexedProperties() -> [String] {
        return ["content"]
    }
    
    override func preSave() {
        super.preSave()
        content.trim()
    }
    
    override func save() -> Bool {
        preSave()
        
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
    
    override func preUpdate() {
        super.preUpdate()
        content.trim()
        updatedAt = Date()
    }
    
    override func update() -> Bool {
        preUpdate()
        do {
            try Realm().write {
                try Realm().add(self, update: true)
            }
            return true
        } catch {
            return false
        }
    }
    
    class func toHuman() -> String {
        return "文字"
    }
    
    class func toMachine() -> String {
        return "word"
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
        return TopListViewModel(id: id, title: title, bookName: "", updatedAt: updateAtString)
    }
}
