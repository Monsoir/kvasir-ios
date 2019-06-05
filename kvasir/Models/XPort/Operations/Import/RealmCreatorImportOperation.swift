//
//  RealmCreatorImportOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/4/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

class RealmCreatorImportOperation<Creator: RealmCreator>: ImportOperation {
    override class var restoreKey: String {
        return Creator.toMachine
    }
    
    override func recover(jsonData: Data) -> (success: Bool, msg: String?, ros: [RealmBasicObject]?, pos: [Codable]?) {
        guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
        
        switch Creator.self {
        case is RealmAuthor.Type:
            return recoverAuthor(jsonData: jsonData)
        case is RealmTranslator.Type:
            return recoverTranslator(jsonData: jsonData)
        default:
            return (false, "模型无法识别", nil, nil)
        }
    }
    
    private func recoverAuthor(jsonData: Data) -> (Bool, String?, [RealmBasicObject]?, [Codable]?) {
        // 将 JSON 二进制数据还原为普通数据
        let decoder = JSONDecoder()
        var results: PlainCreator<RealmAuthor>.Collection.Authors
        do {
            results = try decoder.decode(PlainCreator<RealmAuthor>.Collection.Authors.self, from: jsonData)
        } catch {
            return (false, "数据转换失败", nil, nil)
        }
        
        // 将普通数据转换为 Realm 数据
        let plainObjects = results.authors
        var objectsToBeAdded = [RealmAuthor]()
        for ele in plainObjects {
            guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
            objectsToBeAdded.append(ele.realmObject)
        }
        
        return (true, nil, objectsToBeAdded, plainObjects)
    }
    
    private func recoverTranslator(jsonData: Data) -> (Bool, String?, [RealmBasicObject]?, [Codable]?) {
        // 将 JSON 二进制数据还原为普通数据
        let decoder = JSONDecoder()
        var results: PlainCreator<RealmTranslator>.Collection.Translators
        do {
            results = try decoder.decode(PlainCreator<RealmTranslator>.Collection.Translators.self, from: jsonData)
        } catch {
            return (false, "数据转换失败", nil, nil)
        }
        
        // 将普通数据转换为 Realm 数据
        let plainObjects = results.translators
        var objectsToBeAdded = [RealmTranslator]()
        for ele in plainObjects {
            guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
            objectsToBeAdded.append(ele.realmObject)
        }
        
        return (true, nil, objectsToBeAdded, plainObjects)
    }
}
