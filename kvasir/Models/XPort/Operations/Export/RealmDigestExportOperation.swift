//
//  RealmDigestBackupOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDigestExportOperation<Digest: RealmWordDigest>: ExportOperation {
    override func provideData() -> Data? {
        return autoreleasepool(invoking: { () -> Data? in
            do {
                let realm = try Realm()
                let objects = realm.objects(Digest.self)
                
                // 将 Realm 数据转换为基本数据
                var plainObjects = [PlainWordDigest<Digest>]()
                for data in objects {
                    guard !isCancelled else { return nil }
                    let object = PlainWordDigest<Digest>(object: data)
                    plainObjects.append(object)
                }
                
                guard !isCancelled else { return nil }
                
                // 将「基本数据」转换为 JSON 二进制数据
                switch Digest.self {
                case is RealmSentence.Type:
                    let digests = PlainWordDigest<Digest>.Collection.Sentences(sentences: plainObjects as! [PlainWordDigest<RealmSentence>])
                    var jsonData: Data
                    do {
                        jsonData = try JSONEncoder().encode(digests)
                        return jsonData
                    } catch {
                        cancel()
                    }
                case is RealmParagraph.Type:
                    let digests = PlainWordDigest<Digest>.Collection.Paragraphs(paragraphs: plainObjects as! [PlainWordDigest<RealmParagraph>])
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
