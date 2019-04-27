//
//  TopListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift

enum CoordinatorMode {
    case local
    case remote
}

class TopListCoordinator {
    private var mode = CoordinatorMode.local
    private var digestType = DigestType.sentence
    private var data = [TopListViewModel]() {
        didSet {
            reload?(data)
        }
    }
    
    private var realmNotificationToken: NotificationToken? = nil
    
    var reload: ((_ data: [TopListViewModel]) -> Void)?
    
    init(mode: CoordinatorMode = .local, digestType: DigestType = .sentence) {
        self.mode = mode
        self.digestType = digestType
    }
    
    deinit {
        realmNotificationToken?.invalidate()
        
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func reclaim() {
        realmNotificationToken?.invalidate()
    }
    
    func fetchData() {
        switch mode {
        case .local:
            fetchLocalData()
        case .remote:
            fetchRemoteData()
        }
    }
    
    private func fetchLocalData() {
        switch digestType {
        case .sentence:
            guard let results = RealmSentence.allObjectsSortedByUpdatedAt(of: RealmSentence.self) else { return }
            func loadTopSentence() -> [TopListViewModel] {
                let showCount = results.count > 5 ? 5 : results.count
                var payload = [TopListViewModel]()
                for i in 0..<showCount {
                    let ele = results[i] 
                    let vm = ele.displayOutline()
                    payload.append(vm)
                }
                return payload
            }
            
            realmNotificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial: fallthrough
                case .update:
                    self?.data = loadTopSentence()
                case .error:
                    return
                }
            }
            
        case .paragraph:
            guard let results = RealmParagraph.allObjectsSortedByUpdatedAt(of: RealmParagraph.self) else { return }
            func loadTopParagraph() -> [TopListViewModel] {
                let showCount = results.count > 5 ? 5 : results.count
                var payload = [TopListViewModel]()
                for i in 0..<showCount {
                    let ele = results[i]
                    let vm = ele.displayOutline()
                    payload.append(vm)
                }
                return payload
            }
            
            realmNotificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
                switch changes {
                case .initial: fallthrough
                case .update:
                    self?.data = loadTopParagraph()
                case .error:
                    return
                }
            }
        }
    }
    
    private func fetchRemoteData() {
    }
}
