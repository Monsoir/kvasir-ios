//
//  RealmDigestBackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDigestExportOperation: ExportOperation {
    override func provideData() -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            do {
                let realm = try Realm()
                let objects = realm.objects(RealmWordDigest.self)
                
                // 将 Realm 数据转换为基本数据
                var plainObjects = [PlainWordDigest]()
                for data in objects {
                    guard !isCancelled else { return nil }
                    let object = PlainWordDigest(object: data)
                    plainObjects.append(object)
                }
                
                guard !isCancelled else { return nil }
                
                // 将「基本数据」转换为 JSON 二进制数据
                let digests = PlainWordDigest.Collection(digests: plainObjects)
                var jsonData: Data
                do {
                    jsonData = try JSONEncoder().encode(digests)
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
