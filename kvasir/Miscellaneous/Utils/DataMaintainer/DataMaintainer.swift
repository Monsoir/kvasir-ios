//
//  DataMaintainer.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import SSZipArchive

// 对 DataMainter 状态的所有读写操作，都在 DataMaintainerSerialQueue 中串行进行
let DataMaintainerSerialQueue = DispatchQueue(label: "kvasir.dataMaintainer.serial.queue")

class DataMaintainer {
    enum Status {
        case normal
        case exporting
        case importing
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
    
    func export(completion: @escaping (_: URL?) -> Void) -> Void {
        DataMaintainerSerialQueue.async {
            guard self.canExport else {
                completion(nil)
                return
            }
            
            self.status = .exporting
            
            GlobalDefaultDispatchQueue.async {
                // 保证备份文件夹存在
                guard Bartendar.Guard.directoryExists(directory: AppConstants.Paths.exportingFileDirectory) else {
                    completion(nil)
                    return
                }
                
                /*
                 导出逻辑：
                 1. 并行备份 RealmBook, RealmTag, RealmSentence, RealmParagraphs, RealmAuthor, RealmTranslator
                 */
                
                // 全部备份任务，但暂时不包括结束任务
                guard var operations = self.createExportOperations() else {
                    completion(nil)
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
                let dateString = dateFormatter.string(from: Date())
                guard let zipPath = SystemDirectories.tmp.url?.appendingPathComponent("backup_\(dateString).zip") else {
                    completion(nil)
                    return
                }
                
                // 压缩任务，将所有备份文件做成一个压缩包
                let compressOperation = BlockOperation {
                    SSZipArchive.createZipFile(atPath: zipPath.droppedScheme()!.absoluteString, withContentsOfDirectory: AppConstants.Paths.exportingFileDirectory!.droppedScheme()!.absoluteString)
                }
                
                // 设置压缩任务依赖
                operations.forEach {
                    compressOperation.addDependency($0)
                }
                operations.append(compressOperation)
                
                // 结束任务封装
                let completeOperation = BlockOperation {
                    DataMaintainerSerialQueue.async {
                        self.status = .normal
                        GlobalDefaultDispatchQueue.async {
                            completion(zipPath)
                        }
                    }
                }
                
                // 设置结束任务的依赖
                operations.forEach {
                    completeOperation.addDependency($0)
                }
                operations.append(completeOperation)
                
                // 将全部任务添加到队列
                let operationQueue = OperationQueue()
                operationQueue.maxConcurrentOperationCount = 3
                operationQueue.addOperations(operations, waitUntilFinished: false)
            }
        }
    }
    
    func `import`() -> Bool {
        guard canImport else { return false }
        return true
    }
    
    private func createExportOperations() -> [Operation]? {
        // 创建 RealmBook 备份任务
        guard let booksBackupOperation = RealmBook.createBackupOperation() else { return nil }
        
        // 创建 RealmTag 备份任务
        guard let tagsBackupOperation = RealmTag.createBackupOperation() else { return nil }
        
        // 创建 RealmSentence 备份任务
        guard let sentencesBackupOperation = RealmSentence.createBackupOperation() else { return nil }
        
        // 创建 RealmParagraph 备份任务
        guard let paragraphsBackupOperation = RealmParagraph.createBackupOperation() else { return nil }
        
        // 创建 RealmAuthor 备份任务
        guard let backupAuthorsTask = RealmAuthor.createBackupOperation() else { return nil }
        
        // 创建 RealmTranslator 备份任务
        guard let backupTranslatorsTask = RealmTranslator.createBackupOperation() else { return nil }
        
        return [
            booksBackupOperation,
            tagsBackupOperation,
            sentencesBackupOperation,
            paragraphsBackupOperation,
            backupAuthorsTask,
            backupTranslatorsTask,
        ]
    }
}
