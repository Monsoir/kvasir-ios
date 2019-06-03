//
//  DataMaintainer.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

//let ExportingQueue = DispatchQueue(label: "kvasir.exporting.queue", qos: DispatchQoS.utility)
//let ImportingQueue = DispatchQueue(label: "kvasir.importing.queue", qos: DispatchQoS.utility)

class DataMaintainer {
    enum Status {
        case normal
        case exporing
        case imporing
    }
    
    private var status: Status = .normal
    
    static let shared: DataMaintainer = {
        let maintainer = DataMaintainer()
        return maintainer
    }()
    private init() {}
}

extension DataMaintainer {
    var canExport: Bool {
        return status == .normal
    }
    
    var canImport: Bool {
        return status == .normal
    }
    
    func export(completion: @escaping () -> Void) -> Bool {
        guard canExport else { return false }
        
        /*
         导出逻辑：
            1. 并行备份 RealmBook, RealmTag, RealmSentence, RealmParagraphs, RealmAuthor, RealmTranslator
         */
        
        // 创建 RealmBook 备份任务
        guard let booksBackupOperation = RealmBook.createBackupOperation() else { return false }
        
        // 创建 RealmTag 备份任务
        guard let tagsBackupOperation = RealmTag.createBackupOperation() else { return false }
        
        // 创建 RealmSentence 备份任务
        guard let sentencesBackupOperation = RealmSentence.createBackupOperation() else { return false }
        
        // 创建 RealmParagraph 备份任务
        guard let paragraphsBackupOperation = RealmParagraph.createBackupOperation() else { return false }
        
        // 创建 RealmAuthor 备份任务
        guard let backupAuthorsTask = RealmAuthor.createBackupOperation() else { return false }
        
        // 创建 RealmTranslator 备份任务
        guard let backupTranslatorsTask = RealmTranslator.createBackupOperation() else { return false }
        
        // 结束任务封装
        let completeOperation = BlockOperation {
            completion()
        }
        
        // 全部任务，但暂时不包括技术任务
        var operations: [Operation] = [
            booksBackupOperation,
            tagsBackupOperation,
            sentencesBackupOperation,
            paragraphsBackupOperation,
            backupAuthorsTask,
            backupTranslatorsTask,
        ]
        
        // 设置结束任务的依赖
        operations.forEach {
            completeOperation.addDependency($0)
        }
        
        // 将全部任务添加到队列
        operations.append(completeOperation)
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        operationQueue.addOperations(operations, waitUntilFinished: false)
        
        return true
    }
    
    func `import`() -> Bool {
        guard canImport else { return false }
        return true
    }
}
