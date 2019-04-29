//
//  RealmBookRepository.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class RealmBookRepository: Repositorable {
    typealias Model = RealmBook
    
    func preCreate(unmanagedModel: Model) {
        unmanagedModel.name.trim()
        unmanagedModel.localeName.trim()
        unmanagedModel.isbn.trim()
        unmanagedModel.publisher.trim()
    }
    
    func createOne(unmanagedModel: Model, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(unmanagedModel)
                    }
                    completion(true)
                } catch {
                    completion(false)
                }
            })
        }
    }
    
    func preUpdate(managedModel: Model) {
        managedModel.name.trim()
        managedModel.localeName.trim()
        managedModel.isbn.trim()
        managedModel.publisher.trim()
        managedModel.updatedAt = Date()
    }
}
