//
//  RealmDigestImportOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/4/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

class RealmDigestImportOperation: ImportOperation {
    override class var restoreKey: String {
        return RealmWordDigest.toMachine
    }
    
    override func recover(jsonData: Data) -> (Bool, String?, [RealmBasicObject]?, [Codable]?) {
        guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
        
        // 将 JSON 二进制数据还原为普通数据
        let decoder = JSONDecoder()
        var results: PlainWordDigest.Collection
        do {
            results = try decoder.decode(PlainWordDigest.Collection.self, from: jsonData)
        } catch {
            debugPrint("\(self) 失败")
            return (false, "数据转换失败", nil, nil)
        }
        
        // 将普通数据转换为 Realm 数据
        let digests = results.digests
        var objectsToBeAdded = [RealmWordDigest]()
        for ele in digests {
            guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
            
            objectsToBeAdded.append(ele.realmObject)
            // tag 的关系由 RealmTag 负责录入
            // book 的关系由 RealmBook 负责录入
        }
        
        return (true, nil, objectsToBeAdded, digests)
    }
}
