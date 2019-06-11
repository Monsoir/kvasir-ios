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

class RealmCreatorRepository: Repositorable {
    typealias Model = RealmCreator
    
    static let shared: RealmCreatorRepository = {
        let repo = RealmCreatorRepository()
        return repo
    }()
    private init() {}
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func preCreate(unmanagedModel: Model) {
        unmanagedModel.preCreate()
    }
    
    func createOne(unmanagedModel: Model, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
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
    
    func preUpdate(managedModel: Model) {
        managedModel.preUpdate()
    }
}
