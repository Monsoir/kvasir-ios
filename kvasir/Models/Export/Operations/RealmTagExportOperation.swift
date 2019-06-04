//
//  RealmTagBackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmTagExportOperation: ExportOperation {
    override func provideData() -> Data? {
        return autoreleasepool { () -> Data? in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmTag.self)
                
                // 将 Realm 数据转换为基本数据
                var plainTags = [PlainTag]()
                for data in objects {
                    guard !isCancelled else { return nil }
                    
                    let tag = PlainTag(object: data)
                    plainTags.append(tag)
                }
                
                guard !isCancelled else { return nil }
                
                // 将「基本数据」转换为 JSON 二进制数据
                let tags = PlainTag.Collection(tags: plainTags)
                var jsonData: Data
                do {
                    jsonData = try JSONEncoder().encode(tags)
                    return jsonData
                } catch {
                    cancel()
                }
                
            } catch {
                cancel()
            }
            
            return nil
        }
    }
}
