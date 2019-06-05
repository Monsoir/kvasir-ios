//
//  RealmDigestImportOperation.swift
//  kvasir
//
//  Created by Monsoir on 6/4/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

class RealmDigestImportOperation<Digest: RealmWordDigest>: ImportOperation {
    override class var restoreKey: String {
        return Digest.toMachine
    }
    
    override func recover(jsonData: Data) -> (Bool, String?, [RealmBasicObject]?, [Codable]?) {
        guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
        
        switch Digest.self {
        case is RealmSentence.Type:
            return recoverSentences(jsonData: jsonData)
        case is RealmParagraph.Type:
            return recoverParagraphs(jsonData: jsonData)
        default:
            return (false, "模型无法识别", nil, nil)
        }
    }
    
    private func recoverSentences(jsonData: Data) -> (Bool, String?, [RealmBasicObject]?, [Codable]?) {
        // 将 JSON 二进制数据还原为普通数据
        let decoder = JSONDecoder()
        var results: PlainWordDigest<RealmSentence>.Collection.Sentences
        do {
            results = try decoder.decode(PlainWordDigest<RealmSentence>.Collection.Sentences.self, from: jsonData)
        } catch {
            return (false, "数据转换失败", nil, nil)
        }
        
        // 将普通数据转换为 Realm 数据
        let sentences = results.sentences
        var objectsToBeAdded = [RealmSentence]()
        for ele in sentences {
            guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
            
            objectsToBeAdded.append(ele.realmObject)
            // tag 的关系由 RealmTag 负责录入
            // book 的关系由 RealmBook 负责录入
        }
        
        return (true, nil, objectsToBeAdded, sentences)
    }
    
    private func recoverParagraphs(jsonData: Data) -> (Bool, String?, [RealmBasicObject]?, [Codable]?) {
        // 将 JSON 二进制数据还原为普通数据
        let decoder = JSONDecoder()
        var results: PlainWordDigest<RealmParagraph>.Collection.Paragraphs
        do {
            results = try decoder.decode(PlainWordDigest<RealmParagraph>.Collection.Paragraphs.self, from: jsonData)
        } catch {
            return (false, "数据转换失败", nil, nil)
        }
        
        // 将普通数据转换为 Realm 数据
        let paragraphs = results.paragraphs
        var objectsToBeAdded = [RealmParagraph]()
        for ele in paragraphs {
            guard !isCancelled else { return (false, "任务已被取消", nil, nil) }
            
            objectsToBeAdded.append(ele.realmObject)
            // tag 的关系由 RealmTag 负责录入
            // book 的关系由 RealmBook 负责录入
        }
        
        return (true, nil, objectsToBeAdded, paragraphs)
    }
}
