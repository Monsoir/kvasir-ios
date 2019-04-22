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
            guard let results = RealmSentence.allObjectsSortedByUpdatedAt() else { return }
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
            guard let results = RealmParagraph.allObjectsSortedByUpdatedAt() else { return }
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

extension RealmWordDigest {
    func displayOutline() -> TopListViewModel {
        let title: String = {
            var temp = self.content.replacingOccurrences(of: "\n", with: " ")
            let endIndex = temp.index(temp.startIndex, offsetBy: temp.count < DigestTitleLength ? temp.count : DigestTitleLength)
            let range = temp.startIndex ..< endIndex
            temp = String(temp[range])
            return temp.trimmed
        }()
        let updateAtString = updatedAt.string(withFormat: "yyyy-MM-dd")
        return TopListViewModel(id: id, title: title, bookName: bookName, updatedAt: updateAtString)
    }
}
