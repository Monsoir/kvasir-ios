//
//  TextListCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class TextListCoordinator {
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
}
