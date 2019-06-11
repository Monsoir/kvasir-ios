//
//  DataMaintainer.swift
//  kvasir
//
//  Created by Monsoir on 6/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift
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
    private lazy var importCaches = [String: (ros: [RealmBasicObject], pos: [Codable])]()
    
    deinit {
        debugPrint("\(self) deinit")
    }
}

extension DataMaintainer {
    var canExport: Bool {
        return status == .normal
    }
    
    var canImport: Bool {
        return status == .normal
    }
    
    func export(completion: @escaping (_: URL?, _: String?) -> Void) -> Void {
        DataMaintainerSerialQueue.async {
            guard self.canExport else {
                completion(nil, "暂时不能处理导出工作")
                return
            }
            
            self.status = .exporting
            
            GlobalDefaultDispatchQueue.async {
                // 保证备份文件夹存在
                guard Bartendar.Guard.directoryExists(directory: AppConstants.Paths.exportingFileDirectory) else {
                    completion(nil, "创建导出文件失败 - 0")
                    return
                }
                
                /*
                 导出逻辑：
                 1. 并行备份 RealmBook, RealmTag, RealmSentence, RealmParagraphs, RealmAuthor, RealmTranslator
                 */
                
                // 全部备份任务，但暂时不包括结束任务
                guard var operations = self.createExportOperations() else {
                    completion(nil, "创建导出任务失败")
                    return
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
                let dateString = dateFormatter.string(from: Date())
                guard let zipPath = SystemDirectories.tmp.url?.appendingPathComponent("backup_\(dateString).zip") else {
                    completion(nil, "创建导出文件失败 - 1")
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
                            completion(zipPath, nil)
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
    
    func `import`(completion: @escaping ((_: Bool, _: String?) -> Void)) -> Void {
        DataMaintainerSerialQueue.async {
            guard self.canImport else {
                completion(false, "暂时无法处理导入工作")
                return
            }
            
            self.status = .importing
            
            GlobalDefaultDispatchQueue.async {
                /*
                 导入逻辑：
                    1. 解压文件
                    2. 获取解压后的文件路径们
                    3. 将数据转化工作分成多个 Operation
                    4. 数据转换工作完成后，同一线程对数据的关系进行整理，之后写入数据库
                 */
                
                // 还原导入数据文件夹
                guard let importingDirectory = AppConstants.Paths.importingUnzipDirectory,
                    FileManager.default.msr.restoreDirectory(directory: importingDirectory) else {
                        completion(false, "创建导入文件夹失败")
                        return
                }
                
                // 保证还原文件夹存在
                guard Bartendar.Guard.directoryExists(directory: AppConstants.Paths.importingUnzipDirectory) else {
                    completion(false, "创建导入文件失败 - 0")
                    return
                }
                
                // 解压任务
                let uncompressOperation = BlockOperation(block: {
                    SSZipArchive.unzipFile(atPath: AppConstants.Paths.importingFilePath!.droppedScheme()!.absoluteString, toDestination: AppConstants.Paths.importingUnzipDirectory!.droppedScheme()!.absoluteString)
                })
                
                // 还原任务
                guard let restoreOperations = self.createRestoreOperations() else {
                    completion(false, "创建导入任务失败")
                    return
                }
                
                // 设置还原任务的依赖，还原任务依赖解压任务
                restoreOperations.forEach { $0.addDependency(uncompressOperation) }
                
                // 存储分发任务，包含关系恢复
                // 这个任务只用于分发任务，真正的任务使用串行队列 DataMaintainerSerialQueue 进行，防止数据竞争
                let savingDispatchOperation = BlockOperation {
                    DataMaintainerSerialQueue.async {
                        guard let relationsRestoredObjects = self.restoreRelations() else {
                            // 不能继续恢复数据之间的关系任务
                            self.importCaches.removeAll()
                            self.status = .normal // 恢复完成后，恢复状态
                            completion(false, "导入失败")
                            return
                        }
                        
                        RealmWritingQueue.async {
                            // 使用自建的 Realm 专用写队列
                            let savingResult = self.saveToRealm(objects: relationsRestoredObjects)
                            
                            DataMaintainerSerialQueue.async {
                                // 切换回 DataMainter 数据修改专用队列
                                self.importCaches.removeAll()
                                self.status = .normal // 恢复完成后，恢复状态
                                
                                GlobalDefaultDispatchQueue.async {
                                    // 结束任务由于要等到存储任务结束后才执行，因此不能封装为 Operation, 这是由于队列不同，无法同步
                                    completion(savingResult, nil)
                                }
                            }
                        }
                    }
                }
                
                var allOperations = restoreOperations
                allOperations.append(uncompressOperation)
                
                // 设置存储任务依赖，依赖所有其他任务
                allOperations.forEach { savingDispatchOperation.addDependency($0) }
                allOperations.append(savingDispatchOperation)
                
                // 将全部任务添加到队列
                let operationQueue = OperationQueue()
                operationQueue.maxConcurrentOperationCount = 5
                operationQueue.addOperations(allOperations, waitUntilFinished: false)
            }
        }
    }
    
    private func createExportOperations() -> [Operation]? {
        // 创建 RealmBook 备份任务
        guard let booksBackupOperation = RealmBook.createBackupOperation() else { return nil }
        
        // 创建 RealmTag 备份任务
        guard let tagsBackupOperation = RealmTag.createBackupOperation() else { return nil }
        
        // 创建 RealmWordDigest 备份任务
        guard let digestsBackupOperation = RealmWordDigest.createBackupOperation() else { return nil }
        
        // 创建 RealmCreator 备份任务
        guard let creatorsBackupOperation = RealmCreator.createBackupOperation() else { return nil }
        
        return [
            booksBackupOperation,
            tagsBackupOperation,
            digestsBackupOperation,
            creatorsBackupOperation,
        ]
    }
    
    private func createRestoreOperations() -> [Operation]? {
        // 创建 RealmBook 还原任务
        guard let booksRestoreOperation = RealmBook.createRecoverOperation() else { return nil }

        // 创建 RealmTag 还原任务
        guard let tagsRestoreOperation = RealmTag.createRecoverOperation() else { return nil }

        // 创建 RealmSentence 还原任务
        guard let digestsRestoreOperation = RealmWordDigest.createRecoverOperation() else { return nil }

        // 创建 RealmCreator 还原任务
        guard let creatorsRestoreOperation = RealmCreator.createRecoverOperation() else { return nil }
        
        let ops = [
            booksRestoreOperation,
            tagsRestoreOperation,
            digestsRestoreOperation,
            creatorsRestoreOperation,
        ]
        ops.forEach { $0.delegate = self }
        return ops
    }
    
    /// 将数据写入到数据库
    /// - 注意：其中的数据之间的关系应该是恢复了的
    /// - 此方法应在 Realm 的专用写队列中调用
    ///
    /// - Parameter objects: 需要存储数据库的数据，每一种模型的数据为一个数组
    /// - Returns: true 为成功写入，false 为出错
    private func saveToRealm(objects: [[RealmBasicObject]]) -> Bool {
        do {
            let realm = try Realm()
            try realm.write {
                objects.forEach {
                    realm.add($0, update: true)
                }
            }
        } catch {
            return false
        }
        
        return true
    }
    
    private func restoreRelations() -> [[RealmBasicObject]]? {
        return autoreleasepool { () -> [[RealmBasicObject]]? in
            guard let (_creatorRos, _creatorPos) = self.importCaches[RealmCreatorImportOperation.restoreKey] else { return nil }
            guard let (_bookRos, _bookPos) = self.importCaches[RealmBookImportOperation.restoreKey] else { return nil }
            guard let (_tagRos, _tagPos) = self.importCaches[RealmTagImportOperation.restoreKey] else { return nil }
            guard let (_digstRos, _) = self.importCaches[RealmDigestImportOperation.restoreKey] else { return nil }
            
            guard let creatorRos = _creatorRos as? [RealmCreator], let creatorPos = _creatorPos as? [PlainCreator] else { return nil }
            guard let bookRos = _bookRos as? [RealmBook], let bookPos = _bookPos as? [PlainBook] else { return nil }
            
            // 恢复 RealmCreator 对 RealmBook 的关系
            for (index, ele) in creatorPos.enumerated() {
                let creatorRo = creatorRos[index]
                
                let writtenBookIdsOfCurrentCreator = Set<String>(ele.writtenBooks.map { $0.id })
                let translatedBookIdsOfCurrentCreator = Set<String>(ele.translatedBooks.map { $0.id })
                bookRos.forEach {
                    if writtenBookIdsOfCurrentCreator.contains($0.id) {
                        creatorRo.writtenBooks.append($0)
                    }
                    
                    if translatedBookIdsOfCurrentCreator.contains($0.id) {
                        creatorRo.translatedBooks.append($0)
                    }
                }
            }
            
            // 恢复 RealmBook 对 RealmwordDigest 的关系
            guard let digestRos = _digstRos as? [RealmWordDigest] else { return nil }
            for (index, ele) in bookPos.enumerated() {
                let bookRo = bookRos[index]
                let digestIdSet = Set<String>(ele.digestIds)
                digestRos.forEach {
                    if digestIdSet.contains($0.id) {
                        bookRo.digests.append($0)
                        $0.book = bookRo
                    }
                }
            }
            
            guard let tagRos = _tagRos as? [RealmTag], let tagPos = _tagPos as? [PlainTag] else { return nil }
            
            // 恢复 RealmTag 对 RealmwordDigest 的关系
            for (index, ele) in tagPos.enumerated() {
                let tagRo = tagRos[index]
                let digestIdSet = Set<String>(ele.digestIds)
                digestRos.forEach {
                    if digestIdSet.contains($0.id) {
                        tagRo.wordDigests.append($0)
                    }
                }
            }
            
            return [
                tagRos, bookRos, creatorRos, digestRos,
            ]
        }
    }
}

extension DataMaintainer: ImportOperationDeleagte {
    func operation(_ operation: ImportOperation, isCompleted: Bool, msg: String?, ros: [RealmBasicObject]?, pos: [Codable]?) {
        guard isCompleted else { return }
        
        DataMaintainerSerialQueue.async { [weak self] in
            guard let self = self else { return }
            guard let r = ros, let p = pos else { return }
            
            self.importCaches[type(of: operation).restoreKey] = (r, p)
        }
    }
}
