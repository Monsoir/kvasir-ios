//
//  SearchResultCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 6/6/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

typealias DigestSearchResultCoordinator = TopListCoordinator

extension DigestSearchResultCoordinator {
    func setupQuery(by content: String, section: Int = 0) {
        RealmWordRepository<Digest>().queryBy(content: content) { [weak self] (success, results) in
            guard let self = self else { return }
            guard success, let results = results else { return }
            
            self.replace(digestResults: results)
            
            if let token = self.results?.observe({ [weak self] (changes) in
                guard let self = self else { return }
                
                switch changes {
                case .initial:
                    self.initialHandler?(self.results)
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
                self.addRealmNotificationTokens(token)
            }
        }
    }
}
