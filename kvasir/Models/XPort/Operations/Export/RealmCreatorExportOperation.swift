//
//  RealmCreatorBackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCreatorExportOperation: ExportOperation {
    override func provideData() -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmCreator.self)
                
                // 将 Realm 数据转换为基本数据
                var plainObjects = [PlainCreator]()
                for data in objects {
                    guard !isCancelled else { return nil }
                    let object = PlainCreator(object: data)
                    plainObjects.append(object)
                }
                
                guard !isCancelled else { return nil }
                
                // 将「基本数据」转换为 JSON 二进制数据
                let creators = PlainCreator.Collection(creators: plainObjects)
                var jsonData: Data
                do {
                    jsonData = try JSONEncoder().encode(creators)
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
