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
    private var digestType = DigestType.sentence
    private var data = [TopListViewModel]() {
        didSet {
            reload?(data)
        }
    }
    
    private var realmNotificationToken: NotificationToken? = nil
    
    var reload: ((_ data: [TopListViewModel]) -> Void)?
    
    init(digestType: DigestType = .sentence) {
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
