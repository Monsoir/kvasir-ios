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
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
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
                
                let authorIds = otherInfo?["authorIds"] as? [String] ?? []
                let translatorIds = otherInfo?["translators"] as? [String] ?? []
                
                do {
                    let realm = try Realm()
                    
                    let authors = realm.objects(RealmAuthor.self).filter("\(RealmAuthor.primaryKey()!) IN %@", authorIds)
                    let translators = realm.objects(RealmTranslator.self).filter("\(RealmTranslator.primaryKey()!) IN %@", translatorIds)
                    
                    try realm.write {
                        realm.add(unmanagedModel)
                        
                        authors.forEach({ (ele) in
                            ele.books.append(unmanagedModel)
                        })
                        
                        translators.forEach({ (ele) in
                            ele.books.append(unmanagedModel)
                        })
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
