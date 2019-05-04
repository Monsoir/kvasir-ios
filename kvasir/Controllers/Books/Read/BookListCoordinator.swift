//
//  BookListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class BookListCoordinator {
    private lazy var repository = RealmBookRepository()
    private(set) var results: Results<RealmBook>?
    
    private var realmNotificationToken: NotificationToken? = nil
    
    var initialLoadHandler: ((_ results: Results<RealmBook>) -> Void)?
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func reclaim() {
        realmNotificationToken?.invalidate()
    }
    
    func setupQuery() {
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
                    strongSelf.initialLoadHandler?(results)
                case .update(_, let deletions, let insertions, let modifications):
                    strongSelf.updateHandler?(
                        deletions.map { IndexPath(row: $0, section: 0) },
                        insertions.map { IndexPath(row: $0, section: 0) },
                        modifications.map { IndexPath(row: $0, section: 0) }
                    )
                case .error(let e):
                    strongSelf.errorHandler?(e)
                }
            })
        }
    }
    
    func delete(a book: RealmBook, completion: RealmDeleteCompletion?) {
        repository.deleteOne(managedModel: book) { (success) in
            completion?(success)
        }
    }
}
