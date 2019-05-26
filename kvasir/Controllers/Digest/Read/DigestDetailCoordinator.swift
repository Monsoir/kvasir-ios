//
//  TextDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class DigestDetailCoordinator<Digest: RealmWordDigest>: UpdateCoordinatorable {
    private(set) var digestId = ""
    private(set) var entity: Digest?
    private var repository = RealmWordRepository<Digest>()
    private var putInfo = PutInfo()
    
    private var realmNotificationToken: NotificationToken?
    
    var reload: ((_ entity: Digest?) -> Void)?
    var errorHandler: ((_ message: String) -> Void)?
    var entityDeleteHandler: (() -> Void)?
    
    init(digestId: String) {
        self.digestId = digestId
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
            "content": createNotEmptyStringValidator("\(Digest.toHuman())内容")
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
    
    func queryOne(completion: @escaping RealmQueryAnEntityCompletion<Digest>) {
        guard !digestId.isEmpty else {
            completion(false, nil)
            return
        }
        
        repository.queryBy(id: digestId) { [weak self] (success, entity) in
            guard success, let strongSelf = self else {
                self?.errorHandler?("没找到\(Digest.toHuman())")
                return
            }
            
            strongSelf.entity = entity
            strongSelf.realmNotificationToken = strongSelf.entity?.observe({ (changes) in
                switch changes {
                case .change:
                    strongSelf.reload?(entity)
                case .error:
                    strongSelf.errorHandler?("发生未知错误")
                case .deleted:
                    strongSelf.entityDeleteHandler?()
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
        guard let model = entity else {
            completion(false)
            return
        }
        let oldBook = model.book
        let newBook = book
        
        if Digest.self == RealmSentence.self {
            RealmBookRepository.updateManyToOneRelations(newOwner: newBook, oldOwner: oldBook, key: "\(Digest.toMachine())s", inverseKey: "book", elements: [model] as! [RealmSentence] ) { (success) in
                completion(success)
            }
        } else if Digest.self == RealmParagraph.self {
            RealmBookRepository.updateManyToOneRelations(newOwner: newBook, oldOwner: oldBook, key: "\(Digest.toMachine())s", inverseKey: "book", elements: [model] as! [RealmParagraph] ) { (success) in
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
