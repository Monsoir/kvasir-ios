//
//  TopListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import RealmSwift

class TopListCoordinator<Digest: RealmWordDigest> {
    private var data = [TopListViewModel]() {
        didSet {
            reload?(data)
        }
    }
    
    private var realmNotificationToken: NotificationToken? = nil
    
    var reload: ((_ data: [TopListViewModel]) -> Void)?
    
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
        fetchLocalData()
    }
    
    private func fetchLocalData() {
        guard let results = Digest.allObjectsSortedByUpdatedAt(of: Digest.self) else { return }
        func loadTopDigest() -> [TopListViewModel] {
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
                self?.data = loadTopDigest()
            case .error:
                return
            }
        }
    }
}
