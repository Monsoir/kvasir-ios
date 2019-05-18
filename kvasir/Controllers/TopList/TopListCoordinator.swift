//
//  TopListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift

class TopListCoordinator<Digest: RealmWordDigest> {
    var bookName: String {
        return bookResult?.name ?? ""
    }
    private lazy var repository = RealmWordRepository<Digest>()
    
    private(set) var results: Results<Digest>?
    private var bookResult: RealmBook?
    
    private var realmNotificationToken: NotificationToken? = nil
    private var payload: [String: Any]!
    
    var reload: ((_ results: Results<Digest>?) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    init(with payload: [String: Any]? = [:]) {
        self.payload = payload
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        realmNotificationToken?.invalidate()
    }
    
    func setupQuery() {
        if let bookId = payload["bookId"] as? String {
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
                    case .initial: fallthrough
                    case .update:
                        strongSelf.reload?(strongSelf.results)
                    case .error(let e):
                        strongSelf.errorHandler?(e)
                    }
                })
            }
        } else {
            repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, _results) in
                guard success, let results = _results, let strongSelf = self else {
                    return
                }
                
                // link to results
                strongSelf.results = results
                
                // setup notification
                strongSelf.realmNotificationToken = results.observe({ (changes) in
                    switch changes {
                    case .initial: fallthrough
                    case .update:
                        strongSelf.reload?(results)
                    case .error(let e):
                        strongSelf.errorHandler?(e)
                    }
                })
            }
        }
    }
}
