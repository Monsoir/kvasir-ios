//
//  TagListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class TagListCoordinator {
    private lazy var repository = RealmTagRepository()
    private(set) var results: Results<RealmTag>?
    private(set) var configuration: [String: Any]!
    private var realmNotificationToken: NotificationToken? = nil
    
    var initialLoadHandler: ((_ results: Results<RealmTag>) -> Void)?
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    init(with configuration: [String: Any]) {
        self.configuration = configuration
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func reclaim() {
        realmNotificationToken?.invalidate()
    }
    
    func setupQuery() {
        repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, results) in
            guard let self = self, success, let results = results else { return }
            
            self.results = results
            self.realmNotificationToken = results.observe({ (changes) in
                switch changes {
                case .initial:
                    self.initialLoadHandler?(results)
                case .update(_, let deletions, let insertions, let modifications):
                    self.updateHandler?(
                        deletions.map { IndexPath(row: $0, section: 0) },
                        insertions.map { IndexPath(row: $0, section: 0) },
                        modifications.map { IndexPath(row: $0, section: 0) }
                    )
                case .error(let e):
                    self.errorHandler?(e)
                }
            })
        }
    }
}
