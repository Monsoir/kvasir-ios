//
//  RealmBookBackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBookBackupOperation: ExportOperation {
    override func provideData() -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmBook.self)
                
                // 将 Realm 数据转换为基本数据
                var plainBooks = [PlainBook]()
                for ele in objects {
                    if !isCancelled {
                        guard !isCancelled else { return nil }
                        let book = PlainBook(object: ele)
                        plainBooks.append(book)
                    }
                }
                
                guard !isCancelled else { return nil }
                
                // 将「基本数据」转换为 JSON 二进制数据
                let books = PlainBook.Collection(books: plainBooks)
                var jsonData: Data
                do {
                    jsonData = try JSONEncoder().encode(books)
                    return jsonData
                } catch {
                    cancel()
                }
            } catch {
                cancel()
            }
            
            return nil
        })
    }
}
