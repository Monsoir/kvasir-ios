//
//  CreateListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class CreatorListCoordinator<Creator: RealmCreator> {
    private lazy var repository = RealmCreatorRepository<Creator>()
    private(set) var results: Results<Creator>?
    
    private var realmNotificationToken: NotificationToken? = nil
    
    var initialLoadHandler: ((_ results: Results<Creator>) -> Void)?
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
                case .update(_, deletions: let deletions, let insertions, let modifications):
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
    
    func delete(a creator: Creator, completion: RealmDeleteCompletion?) {
        repository.deleteOne(managedModel: creator) { (success) in
            completion?(success)
        }
    }
}
