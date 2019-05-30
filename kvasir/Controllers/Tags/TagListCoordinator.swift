//
//  TagListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class TagListCoordinator: ListQueryCoordinatorable {
    typealias Model = RealmTag
    
    private lazy var repository = RealmTagRepository()
    private(set) var results: Results<RealmTag>?
    private(set) var configuration: Configurable.Configuration
    private(set) var realmNotificationTokens = [NotificationToken]()
    
    var initialHandler: ((Results<RealmTag>?) -> Void)?
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    required init(configuration: Configurable.Configuration = [:]) {
        self.configuration = configuration
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func reclaim() {
        realmNotificationTokens.forEach{ $0.invalidate() }
    }
    
    func setupQuery(for section: Int = 0) {
        repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, results) in
            guard let self = self, success, let results = results else { return }
            
            self.results = results
            if let token = self.results?.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial:
                    self.initialHandler?(results)
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
