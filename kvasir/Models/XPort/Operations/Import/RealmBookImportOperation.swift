//
//  RealmBookImportOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/4/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBookImportOperation: ImportOperation {
    override class var restoreKey: String {
        return RealmBook.toMachine
    }
    
    override func recover(jsonData: Data) -> (success: Bool, msg: String?, ros: [RealmBasicObject]?, pos: [Codable]?) {
        guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
        
        // 将 JSON 二进制数据还原为普通数据
        let decoder = JSONDecoder()
        var results: PlainBook.Collection
        do {
            results = try decoder.decode(PlainBook.Collection.self, from: jsonData)
        } catch {
            return (false, "数据转换失败", nil, nil)
        }
        
        // 将普通数据转换为 Realm 数据
        let books = results.books
        var objectsToBeAdded = [RealmBook]()
        for ele in books {
            guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
            objectsToBeAdded.append(ele.realmObject)
        }
        
        return (true, nil, objectsToBeAdded, books)
    }
}
