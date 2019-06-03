//
//  RealmCreatorBackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCreatorBackupOperation<Creator: RealmCreator>: BackupOperation {
    override func provideData() -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            do {
                let realm = try Realm()
                let objects = realm.objects(Creator.self)
                
                // 将 Realm 数据转换为基本数据
                var plainObjects = [PlainCreator<Creator>]()
                for data in objects {
                    guard !isCancelled else { return nil }
                    let object = PlainCreator<Creator>(object: data)
                    plainObjects.append(object)
                }
                
                guard !isCancelled else { return nil }
                
                // 将「基本数据」转换为 JSON 二进制数据
                switch Creator.self {
                case is RealmAuthor.Type:
                    let authors = PlainCreator<Creator>.Collection.Authors(authors: plainObjects as! [PlainCreator<RealmAuthor>])
                    var jsonData: Data
                    do {
                        jsonData = try JSONEncoder().encode(authors)
                        return jsonData
                    } catch {
                        cancel()
                    }
                case is RealmTranslator.Type:
                    let digests = PlainCreator<Creator>.Collection.Translators(translators: plainObjects as! [PlainCreator<RealmTranslator>])
                    var jsonData: Data
                    do {
                        jsonData = try JSONEncoder().encode(digests)
                        return jsonData
                    } catch {
                        cancel()
                    }
                default:
                    cancel()
                    return nil
                }
                
            } catch {
                cancel()
            }
            
            return nil
        })
    }
}
