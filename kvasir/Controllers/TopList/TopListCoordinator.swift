//
//  TopListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift

class TopListCoordinator: ListQueryCoordinatorable {
    typealias Model = RealmWordDigest
    
    var bookName: String {
        return bookResult?.name ?? ""
    }
//    private lazy var repository = RealmWordRepository<Digest>()
    
    private(set) var results: Results<Model>?
    private var bookResult: RealmBook?
    private var tagResult: RealmTag?
    
    private(set) var realmNotificationTokens = Set<NotificationToken>()
    private(set) var appNotificationTokens = [NSObjectProtocol]()
    private let configuration: Configurable.Configuration
    private var category: Model.Category {
        return (configuration[#keyPath(RealmWordDigest.category)] as? Model.Category) ?? .sentence
    }
    
    var initialHandler: ((Results<Model>?) -> Void)?
    var updateHandler: (([IndexPath], [IndexPath], [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    var tagUpdateHandler: ((_: Set<String>, _: Model.Category) -> Void)?
    private var tagUpdateUserInfo: [AnyHashable: Any]?
    
    required init(configuration: Configurable.Configuration = [:]) {
        self.configuration = configuration
    }
    
    deinit {
        appNotificationTokens.forEach{ NotificationCenter.default.removeObserver($0) }
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        realmNotificationTokens.forEach{ $0.invalidate() }
    }
    
    func setupQuery(for section: Int = 0) {
        if let bookId = configuration["bookId"] as? String {
            // Query digests are related to a specific book
            setupQueryForSpecificBook(bookId: bookId, updatingSection: section)
        } else if let tagId = configuration["tagId"] as? String {
            // Query digests are related to a specific tag
            setupQueryForSpecificTag(tagId: tagId, updatingSection: section)
        } else {
            // query all digests
            setupQueryForAll(updatingSection: section)
        }
        
        // 注册 Digest 与 Tag 关系变化通知
        let willChangeToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AppNotification.Name.relationBetweenDigestAndTagWillChange),
            object: nil,
            queue: nil,
            using: { [weak self] (notif) in
                guard let changeSuccess = notif.userInfo?["changeSuccess"] as? Bool, changeSuccess else { return }
                guard let self = self else { return }
                
                self.tagUpdateUserInfo = notif.userInfo
        })
        appNotificationTokens.append(willChangeToken)
            
        let didChangeToken = NotificationCenter.default.addObserver(
            forName: NSNotification.Name(rawValue: AppNotification.Name.relationBetweenDigestAndTagDidChange),
            object: nil,
            queue: nil) { [weak self] (notif) in
                guard let self = self else { return }
                guard
                    let userInfo = self.tagUpdateUserInfo,
                    let digestIds = userInfo["digestIdSet"] as? Set<String>
                else { return }
                
                self.tagUpdateHandler?(digestIds, self.category)
        }
        appNotificationTokens.append(didChangeToken)
    }
    
    private func setupQueryForSpecificBook(bookId: String, updatingSection section: Int) {
        RealmBookRepository.shared.queryBy(id: bookId) { [weak self] (success, result) in
            guard success, let result = result, let self = self else {
                return
            }
            
            self.bookResult = result
            self.results = result.digests
                                    .filter("\(#keyPath(RealmWordDigest.category)) == %@", self.category.rawValue)
                                    .sorted(byKeyPath: #keyPath(RealmWordDigest.updatedAt), ascending: false)
            
            if let token = self.results?.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    self.initialHandler?(self.results)
                case .update(_, let deletions, let insertions, let modifications):
                    self.updateHandler?(
                        deletions.map { IndexPath(row: $0, section: section) },
                        insertions.map { IndexPath(row: $0, section: section) },
                        modifications.map { IndexPath(row: $0, section: section) }
                    )
                case .error(let e):
                    self.errorHandler?(e)
                }
            }) {
                self.addRealmNotificationTokens(token)
            }
        }
    }
    
    private func setupQueryForSpecificTag(tagId: String, updatingSection section: Int) {
        RealmTagRepository.shared.queryBy(id: tagId) { [weak self] (success, result) in
            guard let self = self else { return }
            guard success, let result = result else { return }
            
            self.tagResult = result
            self.results = result.wordDigests
                                    .filter("\(#keyPath(RealmWordDigest.category)) == %@", self.category.rawValue)
                                    .sorted(byKeyPath: #keyPath(RealmWordDigest.updatedAt), ascending: false)
            
            if let token = self.results?.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    self.initialHandler?(self.results)
                case .update(_, let deletions, let insertions, let modifications):
                    self.updateHandler?(
                        deletions.map { IndexPath(row: $0, section: section) },
                        insertions.map { IndexPath(row: $0, section: section) },
                        modifications.map { IndexPath(row: $0, section: section) }
                    )
                case .error(let e):
                    self.errorHandler?(e)
                }
            }) {
                self.addRealmNotificationTokens(token)
            }
        }
    }
    
    private func setupQueryForAll(updatingSection section: Int) {
        RealmWordRepository.shared.queryAll(by: category.rawValue) { [weak self] (success, _results) in
            guard success, let results = _results, let self = self else {
                return
            }
            
            // link to results
            self.results = results.sorted(byKeyPath: #keyPath(RealmWordDigest.updatedAt), ascending: false)
            
            // setup notification
            if let token = self.results?.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    self.initialHandler?(self.results)
                case .update(_, let deletions, let insertions, let modifications):
                    self.updateHandler?(
                        deletions.map { IndexPath(row: $0, section: section) },
                        insertions.map { IndexPath(row: $0, section: section) },
                        modifications.map { IndexPath(row: $0, section: section) }
                    )
                case .error(let e):
                    self.errorHandler?(e)
                }
            }) {
                self.addRealmNotificationTokens(token)
            }
        }
    }
    
    func addRealmNotificationTokens(_ token: NotificationToken) {
        realmNotificationTokens.insert(token)
    }
    
    func replace(digestResults: Results<Model>?) {
        results = digestResults
    }
    
    func clearResults() {
        results = nil
    }
}
