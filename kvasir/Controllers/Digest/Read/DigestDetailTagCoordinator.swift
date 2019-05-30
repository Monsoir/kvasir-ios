//
//  DigestDetailTagCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/30/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class DigestDetailTagCoordinator<Digest: RealmWordDigest>: ListQueryCoordinatorable, UpdateCoordinatorable {
    typealias Model = RealmTag
    
    private let configuration: Configuration
    private(set) var results: Results<RealmTag>?
    private lazy var repository = RealmTagRepository()
    private var putInfo = PutInfo()
    
    private var realmNotificationToken: NotificationToken?
    
    var initialHandler: ((Results<RealmTag>?) -> Void)?
    var updateHandler: (([IndexPath], [IndexPath], [IndexPath]) -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func reclaim() {
        realmNotificationToken?.invalidate()
    }
    
    func setupQuery(for section: Int) {
        repository.queryAllSortingByUpdatedAtDesc { [weak self] (success, results) in
            guard let self = self, success, let results = results else { return }
            
            self.results = results
            self.realmNotificationToken = results.observe({[weak self] (changes) in
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
            })
        }
    }
    
    func put(info: PutInfoScript) throws {
        putInfo = info as PutInfo
    }
    
    func update(completion: @escaping RealmUpdateCompletion) {
        guard let tagId = putInfo["tagId"] as? String, let digestIds = putInfo["entityIds"] as? [String] else {
            completion(false)
            return
        }
        repository.updateTagToDigestRelation(tagId: tagId, digestType: Digest.self, digestIds: digestIds, completion: completion)
    }
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
}
