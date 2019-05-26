//
//  RealmTagRepository.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift
import SwifterSwift

class RealmTagRepository: Repositorable {
    func createOne(unmanagedModel: RealmTag, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
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
    
    typealias Model = RealmTag
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func preCreate(unmanagedModel: RealmTag) {
        unmanagedModel.preCreate()
    }
    
    func createOne(unmanagedModel: RealmTag, otherInfo: RealmCreateInfo?, update: Bool = false, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.add(unmanagedModel, update: update)
                    }
                    
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func preUpdate(managedModel: RealmTag) {
        managedModel.preUpdate()
    }
    
    func createMultiple(unmanagedModels: [RealmTag], update: Bool, completion: @escaping RealmCreateCompletion) {
        unmanagedModels.forEach{ preCreate(unmanagedModel: $0) }
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.add(unmanagedModels, update: update)
                    }
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
}
