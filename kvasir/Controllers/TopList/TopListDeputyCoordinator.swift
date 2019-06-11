//
//  TopListDeputyCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/16/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift

private struct NotificationTokens {
    var bookToken: NotificationToken? = nil
    var authorToken: NotificationToken? = nil
    var translatorToken: NotificationToken? = nil
    var tagToken: NotificationToken? = nil
    
    func reclaim() {
        [bookToken, authorToken, translatorToken, tagToken].forEach { $0?.invalidate() }
    }
}

class TopListDeputyCoodinator {
    private lazy var bookRepository = RealmBookRepository.shared
    private lazy var creatorRepository = RealmCreatorRepository.shared
    private lazy var tagRepository = RealmTagRepository.shared
    
    private(set) var bookResults: Results<RealmBook>?
    private(set) var authorResults: Results<RealmCreator>?
    private(set) var translatorResults: Results<RealmCreator>?
    private(set) var tagResults: Results<RealmTag>?
    
    private lazy var notificationTokens = NotificationTokens()
    
    var reload: ((_ bookCount: Int, _ authorCount: Int, _ translatorCount: Int, _ tagCount: Int) -> Void)?
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        notificationTokens.reclaim()
    }
    
    func setupQuery() {
        bookRepository.queryAll { [weak self] (success, _results) in
            guard let self = self else { return }
            guard success, let results = _results else {
                return
            }
            
            self.bookResults = results
            self.notificationTokens.bookToken = results.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial: fallthrough
                case .update:
                    self.reload?(
                        self.bookResults?.count ?? 0,
                        self.authorResults?.count ?? 0,
                        self.translatorResults?.count ?? 0,
                        self.tagResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
        
        creatorRepository.queryAll(by: RealmCreator.Category.author.rawValue) { [weak self] (success, results) in
            guard let self = self else { return }
            guard success, let results = results else {
                return
            }
            
            self.authorResults = results
            self.notificationTokens.authorToken = results.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial: fallthrough
                case .update:
                    self.reload?(
                        self.bookResults?.count ?? 0,
                        self.authorResults?.count ?? 0,
                        self.translatorResults?.count ?? 0,
                        self.tagResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
        
        creatorRepository.queryAll(by: RealmCreator.Category.translator.rawValue) { [weak self] (success, results) in
            guard let self = self else { return }
            guard success, let results = results else {
                return
            }
            
            self.translatorResults = results
            self.notificationTokens.translatorToken = results.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial: fallthrough
                case .update:
                    self.reload?(
                        self.bookResults?.count ?? 0,
                        self.authorResults?.count ?? 0,
                        self.translatorResults?.count ?? 0,
                        self.tagResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
        
        tagRepository.queryAll { [weak self] (success, results) in
            guard let self = self else { return }
            guard success, let results = results else {
                return
            }
            
            self.tagResults = results
            self.notificationTokens.tagToken = results.observe({ [weak self] (changes) in
                guard let self = self else { return }
                switch changes {
                case .initial: fallthrough
                case .update:
                    self.reload?(
                        self.bookResults?.count ?? 0,
                        self.authorResults?.count ?? 0,
                        self.translatorResults?.count ?? 0,
                        self.tagResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
    }
}
