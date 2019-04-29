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
    
    var reload: ((_ results: Results<RealmBook>) -> Void)?
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
            
            let resultsRef = ThreadSafeReference(to: results)
            MainQueue.async {
                autoreleasepool(invoking: { () -> Void in
                    let realm = try? Realm()
                    guard let resultsDeref = realm?.resolve(resultsRef) else { return }
                    
                    // link to results
                    strongSelf.results = resultsDeref
                    
                    // setup notification
                    strongSelf.realmNotificationToken = resultsDeref.observe({ (changes) in
                        switch changes {
                        case .initial: fallthrough
                        case .update:
                            strongSelf.reload?(results)
                        case .error(let e):
                            strongSelf.errorHandler?(e)
                        }
                    })
                })
            }
        }
    }
}
