//
//  TopListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift

class TopListCoordinator<Digest: RealmWordDigest>: ListQueryCoordinatorable {
    typealias Model = Digest
    
    var bookName: String {
        return bookResult?.name ?? ""
    }
    private lazy var repository = RealmWordRepository<Digest>()
    
    private(set) var results: Results<Digest>?
    private var bookResult: RealmBook?
    
    private(set) var realmNotificationTokens = [NotificationToken]()
    private let configuration: Configurable.Configuration
    
    var initialHandler: ((Results<Digest>?) -> Void)?
    var updateHandler: (([IndexPath], [IndexPath], [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    var tagUpdateHandler: (() -> Void)?
    
    required init(configuration: Configurable.Configuration = [:]) {
        self.configuration = configuration
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        realmNotificationTokens.forEach{ $0.invalidate() }
    }
    
    func setupQuery(for section: Int = 0) {
        if let bookId = configuration["bookId"] as? String {
            // Query digests are related to a specific book
            setupQueryForSpecificBook(bookId: bookId, updatingSection: section)
        } else {
            // query all digests
            setupQueryForAll(updatingSection: section)
        }
    }
    
    private func setupQueryForSpecificBook(bookId: String, updatingSection section: Int) {
        RealmBookRepository().queryBy(id: bookId) { [weak self] (success, result) in
            guard success, let result = result, let self = self else {
                return
            }
            
            self.bookResult = result
            if Digest.self == RealmSentence.self {
                self.results = result.sentences.sorted(byKeyPath: "updatedAt", ascending: false) as? Results<Digest>
            } else if Digest.self == RealmParagraph.self {
                self.results = result.paragraphs.sorted(byKeyPath: "updatedAt", ascending: false) as? Results<Digest>
            }
            
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
                self.realmNotificationTokens.append(token)
            }
        }
    }
    
    private func setupQueryForAll(updatingSection section: Int) {
        repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, _results) in
            guard success, let results = _results, let self = self else {
                return
            }
            
            // link to results
            self.results = results
            
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
                self.realmNotificationTokens.append(token)
            }
        }
    }
}
