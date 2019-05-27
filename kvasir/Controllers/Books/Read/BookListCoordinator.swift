//
//  BookListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class BookListCoordinator: ListQueryCoordinatorable {
    
    typealias Model = RealmBook
    
    private lazy var repository = RealmBookRepository()
    private(set) var results: Results<RealmBook>?
    private(set) var configuration: [String: Any]!
    private var realmNotificationToken: NotificationToken? = nil
    
    var initialHandler: ((Results<RealmBook>?) -> Void)?
    var updateHandler: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modificationIndexPaths: [IndexPath]) -> Void)?
    var errorHandler: ((_ error: Error) -> Void)?
    
    required init(with configuration: [String : Any]?) {
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
    
    func setupQuery(for section: Int = 0) {
        func setupResult(results: Results<RealmBook>) {
            // link to results
            self.results = results
            
            // setup notification
            realmNotificationToken = results.observe({ (changes) in
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
        
        if let creatorId = configuration["creatorId"] as? String, !creatorId.isEmpty {
            let creatoryType = configuration["creatorType"] as? String
            if creatoryType == "translator" {
                repository.queryByCreatorId(creatorId, creatorType: RealmTranslator.self) { (success, _results) in
                    guard success, let results = _results else {
                        return
                    }
                    setupResult(results: results)
                }
            } else {
                repository.queryByCreatorId(creatorId, creatorType: RealmAuthor.self) { (success, _results) in
                    guard success, let results = _results else {
                        return
                    }
                    setupResult(results: results)
                }
            }
        } else {
            repository.queryAllSortingByUpdatedAtDesc { (success, _results) in
                guard success, let results = _results else {
                    return
                }
                setupResult(results: results)
            }
        }
    }
    
    func queryBookFromRemote(isbn: String?, completion: @escaping ((Bool, [String: Any]?, String?) -> Void)) {
        guard let isbn = isbn, isbn.msr.isISBN else {
            completion(false, nil, "ISBN 不符合规范")
            return
        }
        
        ProxySessionManager.shared
            .request(BookProxyEndpoint.search(isbn: isbn))
            .validate(statusCode: 200..<300)
            .responseJSON(queue: GlobalDefaultDispatchQueue, options: .allowFragments, completionHandler: { (response) in
                guard let data = ProxySessionManager.handleResponse(response) else { return }
                completion(true, data, nil)
            })
    }
}
