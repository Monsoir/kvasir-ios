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
    
    func reclaim() {
        [bookToken, authorToken, translatorToken].forEach { $0?.invalidate() }
    }
}

class TopListDeputyCoodinator {
    private lazy var bookRepository = RealmBookRepository()
    private lazy var authorRepository = RealmCreatorRepository<RealmAuthor>()
    private lazy var translatorRepository = RealmCreatorRepository<RealmTranslator>()
    
    private(set) var bookResults: Results<RealmBook>?
    private(set) var authorResults: Results<RealmAuthor>?
    private(set) var translatorResults: Results<RealmTranslator>?
    
    private lazy var notificationTokens = NotificationTokens()
    
    var reload: ((_ bookCount: Int, _ authorCount: Int, _ translatorCount: Int) -> Void)?
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func reclaim() {
        notificationTokens.reclaim()
    }
    
    func setupQuery() {
        bookRepository.queryAll { [weak self] (success, _results) in
            guard success, let results = _results, let strongSelf = self else {
                return
            }
            
            strongSelf.bookResults = results
            strongSelf.notificationTokens.bookToken = results.observe({ (changes) in
                switch changes {
                case .initial: fallthrough
                case .update:
                    strongSelf.reload?(
                        strongSelf.bookResults?.count ?? 0,
                        strongSelf.authorResults?.count ?? 0,
                        strongSelf.translatorResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
        
        authorRepository.queryAll { [weak self] (success, _results) in
            guard success, let results = _results, let strongSelf = self else {
                return
            }
            
            strongSelf.authorResults = results
            strongSelf.notificationTokens.authorToken = results.observe({ (changes) in
                switch changes {
                case .initial: fallthrough
                case .update:
                    strongSelf.reload?(
                        strongSelf.bookResults?.count ?? 0,
                        strongSelf.authorResults?.count ?? 0,
                        strongSelf.translatorResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
        
        translatorRepository.queryAll { [weak self] (success, _results) in
            guard success, let results = _results, let strongSelf = self else {
                return
            }
            
            strongSelf.translatorResults = results
            strongSelf.notificationTokens.translatorToken = results.observe({ (changes) in
                switch changes {
                case .initial: fallthrough
                case .update:
                    strongSelf.reload?(
                        strongSelf.bookResults?.count ?? 0,
                        strongSelf.authorResults?.count ?? 0,
                        strongSelf.translatorResults?.count ?? 0
                    )
                default:
                    break
                }
            })
        }
    }
}
