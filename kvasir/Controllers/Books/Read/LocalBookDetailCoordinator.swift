//
//  LocalBookDetailCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class LocalBookDetailCoordinator: BookDetailCoordinator {
    override var mightAddedManully: Bool {
        return thumbnail.isEmpty && summary.isEmpty
    }
    
    override var id: String {
        return entity?.id ?? ""
    }
    
    override var thumbnail: String {
        return entity?.thumbnailImage ?? ""
    }
    
    override var title: String {
        return entity?.name ?? ""
    }
    
    override var authors: String {
        return entity?.authors.map{ $0.name }.joined(separator: "/") ?? ""
    }
    
    override var detail: String {
        return authors
    }
    
    override var summary: String {
        return entity?.summary ?? ""
    }
    
    override var binding: String {
        return ""
    }
    
    override var isbn13: String {
        return entity?.isbn13 ?? ""
    }
    
    override var isbn10: String {
        return entity?.isbn10 ?? ""
    }
    
    override var originTitle: String {
        return entity?.name ?? ""
    }
    
    override var pages: Int {
        return 0
    }
    
    override var price: String {
        return ""
    }
    
    override var publisher: String {
        return entity?.publisher ?? ""
    }
    
    override var translators: String {
        return entity?.translators.map{ $0.name }.joined(separator: "/") ?? ""
    }
    
    override var payloadForHeader: [String: Any] {
        return [
            "thumbnail": thumbnail,
            "title": title,
            "detail": authors,
        ]
    }
    
    var sentencesCount: Int {
        return entity?.sentences.count ?? 0
    }
    
    var paragraphsCount: Int {
        return entity?.paragraphs.count ?? 0
    }
    
    private lazy var repository = RealmBookRepository()
    private var entity: RealmBook?
    
    override func query(_ completion: @escaping BookDetailQueryCompletion) {
        guard let bookId = configuraion["id"] as? String else {
            return
        }
        repository.queryBy(id: bookId) { [weak self] (success, entity) in
            guard let strongSelf = self else { return }
            
            strongSelf.entity = entity
            strongSelf.notificationToken = strongSelf.entity?.observe({ (changes) in
                switch changes {
                case .change:
                    strongSelf.reload?(entity)
                case .error:
                    strongSelf.errorHandler?("未找到该书籍信息")
                case .deleted:
                    strongSelf.entityDeleteHandler?()
                }
            })
            completion(true, entity, nil)
        }
    }
    
    func delete(completion: RealmDeleteCompletion?) {
        guard let entity = entity else { return }
        repository.deleteOne(managedModel: entity) { (success) in
            completion?(success)
        }
    }
    
    override func reclaim() {
        [notificationToken].forEach { $0?.invalidate() }
    }
}
