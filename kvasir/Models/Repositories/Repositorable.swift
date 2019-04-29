//
//  Repositorable.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

typealias RealmCreateCompletion = (_ success: Bool) -> Void
typealias RealmQueryResultsCompletion<T: RealmCollectionValue> = (_ success: Bool, _ results: Results<T>?) -> Void
typealias RealmQueryAnEntityCompletion<T: RealmBasicObject> = (_ success: Bool, _ result: T?) -> Void
typealias RealmUpdateCompletion = (_ success: Bool) -> Void
typealias RealmDeleteCompletion = (_ success: Bool) -> Void

typealias RealmCreateInfo = [String: Any]

struct RealmUpdateInfo {
    var key: String
    var newValue: Any?
}

protocol Repositorable {
    associatedtype Model: RealmBasicObject
    
    // C
    func preCreate(unmanagedModel: Model)
    func createOne(unmanagedModel: Model, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion)
    
    // R
    
    func queryAll(completion: @escaping RealmQueryResultsCompletion<Model>)
    func queryBy(id: String, completion: @escaping RealmQueryAnEntityCompletion<Model>)
    
    // U
    func preUpdate(managedModel: Model)
    func updateOne(managedModel: Model, propertiesExcludingRelations properties: [RealmUpdateInfo], completion: @escaping RealmUpdateCompletion)
    func queryAllSortingByUpdatedAtDesc(completion: @escaping RealmQueryResultsCompletion<Model>)
    
    static func updateManyToOneRelations<Owner: RealmBasicObject, Digest: RealmWordDigest>(newOwner: Owner,
                                                                                           oldOwner: Owner?,
                                                                                           key: String,
                                                                                           inverseKey: String,
                                                                                           elements: [Digest],
                                                                                           completion: @escaping RealmSaveCompletion)
    
    // D
    func deleteOne(managedModel: Model, completion: @escaping RealmDeleteCompletion)
}

extension Repositorable {
    
    // R
    func queryAll(completion: @escaping RealmQueryResultsCompletion<Model>) {
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let objects = realm.objects(Model.self)
                    completion(true, objects)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func queryAllSortingByUpdatedAtDesc(completion: @escaping RealmQueryResultsCompletion<Model>) {
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let objects = realm.objects(Model.self).sorted(byKeyPath: "updatedAt", ascending: false)
                    completion(true, objects)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func queryBy(id: String, completion: @escaping RealmQueryAnEntityCompletion<Model>) {
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let object = realm.object(ofType: Model.self, forPrimaryKey: id)
                    completion(true, object)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    // U
    func updateOne(managedModel: Model, propertiesExcludingRelations properties: [RealmUpdateInfo], completion: @escaping RealmUpdateCompletion) {
        let modelRef = ThreadSafeReference(to: managedModel)
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    guard let modelDeref = realm.resolve(modelRef) else {
                        completion(false)
                        return
                    }
                    
                    try realm.write {
                        modelDeref.preUpdate()
                        
                        properties.forEach({ (info) in
                            modelDeref.setValue(info.newValue, forKey: info.key)
                        })
                    }
                    
                    completion(true)
                } catch {
                    completion(false)
                }
            })
        }
    }
    
    // D
    func deleteOne(managedModel: Model, completion: @escaping RealmDeleteCompletion) {
        let modelRef = ThreadSafeReference(to: managedModel)
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    guard let modelDeref = realm.resolve(modelRef) else {
                        completion(false)
                        return
                    }
                    
                    realm.delete(modelDeref)
                    completion(true)
                } catch {
                    completion(false)
                }
            })
        }
    }
    
    static func updateManyToOneRelations<Owner: RealmBasicObject, Digest: RealmWordDigest>(newOwner: Owner,
                                                                                           oldOwner: Owner?,
                                                                                           key: String,
                                                                                           inverseKey: String,
                                                                                           elements: [Digest],
                                                                                           completion: @escaping RealmSaveCompletion) {
        let newOwnerRef = ThreadSafeReference(to: newOwner)
        let oldOwnerRef = oldOwner == nil ? nil : ThreadSafeReference(to: oldOwner!)
        let elementRefs = elements.map { (ele) -> ThreadSafeReference<Digest> in
            return ThreadSafeReference(to: ele)
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let realm = try Realm()
                guard let newOwnerDeref = realm.resolve(newOwnerRef) else {
                    completion(false)
                    return
                }
                
                var elementDerefs = [Digest]()
                elementRefs.forEach({ (ele) in
                    if let e = realm.resolve(ele) {
                        elementDerefs.append(e)
                    }
                })
                
                let oldOwnerDeref = oldOwnerRef == nil ? nil : realm.resolve(oldOwnerRef!)
                
                try realm.write {
                    elementDerefs.forEach({ (ele) in
                        // old
                        if let list = oldOwnerDeref?.value(forKey: key) as? List<Digest>, let index = list.index(of: ele) {
                            list.remove(at: index)
                        }
                        
                        // new
                        if let list = newOwnerDeref.value(forKey: key) as? List<Digest>, !list.contains(ele) {
                            list.append(ele)
                        }
                        ele.setValue(newOwnerDeref, forKey: inverseKey)
                    })
                }
                
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
}
