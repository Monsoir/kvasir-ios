//
//  TextDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class DigestDetailCoordinator: UpdateCoordinatorable {
    private let configuation: Configurable.Configuration
    var digestId: String {
        return configuation["id"] as? String ?? ""
    }
    private(set) var entity: RealmWordDigest?
    /// Digest 对应标签的集合
    private(set) var tagIdSet: Set<String>?
    private var repository = RealmWordRepository.shared
    private var putInfo = PutInfo()
    
    private var realmNotificationToken: NotificationToken?
    
    private var tagSection: Int {
        return configuation["tagSection"] as? Int ?? 0
    }
    
    var reload: ((_ entity: RealmWordDigest?) -> Void)?
    var errorHandler: ((_ message: String) -> Void)?
    var entityDeleteHandler: (() -> Void)?
    
    required init(configuration: Configurable.Configuration = [:]) {
        self.configuation = configuration
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func reclaim() {
        self.realmNotificationToken?.invalidate()
    }
    
    func put(info: PutInfoScript) throws {
        let validators: [String: SimpleValidator] = [
            "content": createNotEmptyStringValidator("\(entity?.category.toHuman ?? "")内容")
        ]
        
        do {
            try info.keys.forEach { (key) -> Void in
                if let validator = validators[key] {
                    do {
                        try validator(info[key] as Any)
                    } catch let e {
                        throw e
                    }
                }
            }
        } catch let e {
            throw e
        }
        
        putInfo = info as PutInfo
    }
    
    
    /// 此方法应在查询出结果所在的后台线程中调用，避免主线程计算非 UI 事务
    func assembleTagIds() {
        // 在这个后台线程中，将当前 Digest 的标签组成一个集合（避免在主线程中执行）
        // 方便列表展示(列表只需进行即场对比)
        self.tagIdSet = entity?.tagIdSet
    }
    
    func queryOne(completion: @escaping RealmQueryAnEntityCompletion<RealmWordDigest>) {
        guard !digestId.isEmpty else {
            completion(false, nil)
            return
        }
        
        repository.queryBy(id: digestId) { [weak self] (success, entity) in
            guard let self = self else { return }
            guard success else {
                self.errorHandler?("没找到数据")
                return
            }
            
            self.entity = entity
            self.realmNotificationToken = self.entity?.observe({[weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .change:
                    self.reload?(entity)
                case .error:
                    self.errorHandler?("发生未知错误")
                case .deleted:
                    self.entityDeleteHandler?()
                }
            })
            completion(success, entity)
        }
    }
    
    func update(completion: @escaping RealmUpdateCompletion) {
        guard let entity = entity else {
            completion(false)
            return
        }
        repository.updateOne(managedModel: entity, propertiesExcludingRelations: putInfo) { (success) in
            completion(success)
        }
    }
    
    func updateBookRef(book: RealmBook, completion: @escaping RealmSaveCompletion) {
        guard let model = entity, let entity = entity else {
            completion(false)
            return
        }
        let oldBook = model.book
        let newBook = book
        
        switch entity.category {
        case .sentence:
            RealmBookRepository.updateManyToOneRelations(newOwner: newBook, oldOwner: oldBook, key: "digests", inverseKey: #keyPath(RealmWordDigest.book), elements: [model]) { (success) in
                completion(success)
            }
        default:
            RealmBookRepository.updateManyToOneRelations(newOwner: newBook, oldOwner: oldBook, key: "digests", inverseKey: #keyPath(RealmWordDigest.book), elements: [model] ) { (success) in
                completion(success)
            }
        }
    }
    
    func delete(completion: @escaping RealmSaveCompletion) {
        guard let entity = entity else {
            completion(false)
            return
        }
        repository.deleteOne(managedModel: entity) { (success) in
            completion(success)
        }
    }
}
