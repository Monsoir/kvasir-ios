//
//  CreateListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class CreatorListCoordinator<Creator: RealmCreator>: ListQueryCoordinatorable {
    var initialLoadHandler: ((Results<Creator>?) -> Void)?
    
    typealias Model = Creator
    
    private lazy var repository = RealmCreatorRepository<Creator>()
    private(set) var results: Results<Creator>?
    private let configuration: [String: Any]
    
    private(set) var realmNotificationTokens = [NotificationToken]()
    
    var initialHandler: ((_ results: Results<Creator>?) -> Void)?
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    required init(configuration: [String : Any] = [:]) {
        self.configuration = configuration
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        realmNotificationTokens.forEach{ $0.invalidate() }
    }
    
    func setupQuery(for section: Int = 0) {
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
                    self.initialLoadHandler?(self.results)
                case .update(_, deletions: let deletions, let insertions, let modifications):
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
    
    func delete(a creator: Creator, completion: RealmDeleteCompletion?) {
        repository.deleteOne(managedModel: creator) { (success) in
            completion?(success)
        }
    }
}
