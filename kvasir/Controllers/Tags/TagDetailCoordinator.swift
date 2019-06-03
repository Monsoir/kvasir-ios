//
//  TagDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class TagDetailCoordinator: Configurable, UpdateCoordinatorable {
    private(set) var tagResult: RealmTag?
    var reloadHandler: ((_ entity: RealmTag?) -> Void)?
    var errorHandler: ((_ message: String) -> Void)?
    var deleteHandler: (() -> Void)?
    
    var hasSentences: Bool {
        return (tagResult?.sentences.count ?? 0) > 0
    }
    
    var hasParagraphs: Bool {
        return (tagResult?.paragraphs.count ?? 0) > 0
    }
    
    private lazy var tagRepository = RealmTagRepository()
    private var notificationToken: NotificationToken?
    private var configuration: [String: Any]
    private var putInfo = PutInfo()
    
    private var tagId: String {
        return configuration["id"] as? String ?? ""
    }
    
    required init(configuration: [String : Any] = [:]) {
        self.configuration = configuration
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func query(completion: @escaping RealmQueryAnEntityCompletion<RealmTag>) {
        guard !tagId.isEmpty else {
            completion(false, nil)
            return
        }
        
        tagRepository.queryBy(id: tagId) { [weak self] (success, tag) in
            guard let self = self else { return }
            guard let tag = tag else {
                self.errorHandler?("没找到\(RealmTag.toHuman)")
                return
            }
            
            self.tagResult = tag
            self.notificationToken = self.tagResult?.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .change:
                    self.reloadHandler?(self.tagResult)
                case .error:
                    self.errorHandler?("发生未知错误")
                case .deleted:
                    self.deleteHandler?()
                }
            })
            
            completion(true, tag)
        }
    }
    
    func put(info: PutInfoScript) throws {
        let validators: [String: SimpleValidator] = [
            "name": createNotEmptyStringValidator("\(RealmTag.toHuman)名字"),
        ]
        
        for key in validators.keys {
            if let validator = validators[key] {
                do {
                    try validator(info[key] as Any)
                } catch let e {
                    throw e
                }
            }
        }
        
        putInfo = info as PutInfo
    }
    
    func update(completion: @escaping RealmUpdateCompletion) {
        guard let entity = tagResult else {
            completion(false)
            return
        }
        tagRepository.updateOne(managedModel: entity, propertiesExcludingRelations: putInfo, completion: completion)
    }
}
