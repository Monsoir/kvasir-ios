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
    
    private var realmNotificationToken: NotificationToken? = nil
    private var payload: [String: Any]!
    
    var initialHandler: ((Results<Digest>?) -> Void)?
    var updateHandler: (([IndexPath], [IndexPath], [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    required init(with configuration: [String : Any]? = [:]) {
        self.payload = configuration
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        realmNotificationToken?.invalidate()
    }
    
    func setupQuery(for section: Int = 0) {
        if let bookId = payload["bookId"] as? String {
            // Query digests are related to a specific book
            RealmBookRepository().queryBy(id: bookId) { [weak self] (success, result) in
                guard success, let result = result, let strongSelf = self else {
                    return
                }
                
                strongSelf.bookResult = result
                if Digest.self == RealmSentence.self {
                    strongSelf.results = result.sentences.sorted(byKeyPath: "updatedAt", ascending: false) as? Results<Digest>
                } else if Digest.self == RealmParagraph.self {
                    strongSelf.results = result.paragraphs.sorted(byKeyPath: "updatedAt", ascending: false) as? Results<Digest>
                }
                
                strongSelf.realmNotificationToken = strongSelf.results?.observe({ (changes) in
                    switch changes {
                    case .initial:
                        strongSelf.initialHandler?(strongSelf.results)
                    case .update(_, let deletions, let insertions, let modifications):
                        strongSelf.updateHandler?(
                            deletions.map { IndexPath(row: $0, section: section) },
                            insertions.map { IndexPath(row: $0, section: section) },
                            modifications.map { IndexPath(row: $0, section: section) }
                        )
                    case .error(let e):
                        strongSelf.errorHandler?(e)
                    }
                })
            }
        } else {
            // query all digests
            repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, _results) in
                guard success, let results = _results, let strongSelf = self else {
                    return
                }
                
                // link to results
                strongSelf.results = results
                
                // setup notification
                strongSelf.realmNotificationToken = results.observe({ (changes) in
                    switch changes {
                    case .initial:
                        strongSelf.initialHandler?(strongSelf.results)
                    case .update(_, let deletions, let insertions, let modifications):
                        strongSelf.updateHandler?(
                            deletions.map { IndexPath(row: $0, section: section) },
                            insertions.map { IndexPath(row: $0, section: section) },
                            modifications.map { IndexPath(row: $0, section: section) }
                        )
                    case .error(let e):
                        strongSelf.errorHandler?(e)
                    }
                })
            }
        }
    }
}
