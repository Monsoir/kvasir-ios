//
//  TagDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class TagDetailCoordinator: Configurable {
    
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
    
    var hasBooks: Bool {
        return (tagResult?.books.count ?? 0) > 0
    }
    
    private lazy var tagRepository = RealmTagRepository()
    private var notificationToken: NotificationToken?
    private var configuration: [String: Any]
    
    private var tagId: String {
        return configuration["id"] as? String ?? ""
    }
    
    required init(with configuration: [String : Any] = [:]) {
        self.configuration = configuration
    }
    
    func query(completion: @escaping RealmQueryAnEntityCompletion<RealmTag>) {
        guard !tagId.isEmpty else {
            completion(false, nil)
            return
        }
        
        tagRepository.queryBy(id: tagId) { [weak self] (success, tag) in
            guard let self = self else { return }
            guard let tag = tag else {
                self.errorHandler?("没找到\(RealmTag.toHuman())")
                return
            }
            
            self.tagResult = tag
            self.notificationToken = self.tagResult?.observe({ (changes) in
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
}
