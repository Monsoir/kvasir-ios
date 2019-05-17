//
//  RealmCreatorRepository.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift
import SwifterSwift

class RealmCreatorRepository<T: RealmCreator>: Repositorable {
    typealias Model = T
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func preCreate(unmanagedModel: T) {
        unmanagedModel.name.trim()
        unmanagedModel.localeName.trim()
    }
    
    func createOne(unmanagedModel: T, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(unmanagedModel)
                    }
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func preUpdate(managedModel: T) {
        managedModel.name.trim()
        managedModel.localeName.trim()
        managedModel.updatedAt = Date()
    }
}
