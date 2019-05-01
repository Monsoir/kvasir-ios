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
typealias RealmUpdateInfo = RealmCreateInfo

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
    func updateOne(managedModel: Model, propertiesExcludingRelations properties: RealmUpdateInfo, completion: @escaping RealmUpdateCompletion)
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
    
    
    /// 将查询出来的单个对象传回到 main queue 执行，逻辑中包含了为对象配置线程保护
    ///
    /// - Parameters:
    ///   - objectRef: 未配置有线程保护罩的对象
    ///   - okHandler: 定义为成功时的回调
    ///   - notOkHandler: 定义为失败时的回调
    private static func switchBackToMainQueue(object: Model, okHandler: @escaping ((_ objectDeref: Model) -> Void), notOkHandler: @escaping (() -> Void)) {
        let objectRef = ThreadSafeReference(to: object)
        MainQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    guard let objectdeRef = realm.resolve(objectRef) else {
                        notOkHandler()
                        return
                    }
                    okHandler(objectdeRef)
                } catch {
                    notOkHandler()
                }
            })
        }
    }
    
    /// 将查询出来的对象集合传回到 main queue 执行，逻辑中包含了为对象配置线程保护
    ///
    /// - Parameters:
    ///   - objectRef: 未配置有线程保护罩的对象
    ///   - okHandler: 定义为成功时的回调
    ///   - notOkHandler: 定义为失败时的回调
    private static func switchBackToMainQueue(objects: Results<Model>, okHandler: @escaping ((_ objectsDeref: Results<Model>) -> Void), notOkHandler: @escaping (() -> Void)) {
        let objectsRef = ThreadSafeReference(to: objects)
        MainQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    guard let objectsdeRef = realm.resolve(objectsRef) else {
                        notOkHandler()
                        return
                    }
                    okHandler(objectsdeRef)
                } catch {
                    notOkHandler()
                }
            })
        }
    }
    
    // R
    func queryAll(completion: @escaping RealmQueryResultsCompletion<Model>) {
        UserInitiatedGlobalDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let objects = realm.objects(Model.self)
                    
                    Self.switchBackToMainQueue(objects: objects, okHandler: { (objectsDeref) in
                        completion(true, objectsDeref)
                    }, notOkHandler: {
                        completion(false, nil)
                    })
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
                    Self.switchBackToMainQueue(objects: objects, okHandler: { (objectsDeref) in
                        completion(true, objectsDeref)
                    }, notOkHandler: {
                        completion(false, nil)
                    })
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
                    
                    guard let entity = object else {
                        completion(false, nil)
                        return
                    }
                    Self.switchBackToMainQueue(object: entity, okHandler: { (object) in
                        completion(true, object)
                    }, notOkHandler: {
                        completion(false, nil)
                    })
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    // U
    func updateOne(managedModel: Model, propertiesExcludingRelations properties: RealmUpdateInfo, completion: @escaping RealmUpdateCompletion) {
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
                        self.preUpdate(managedModel: modelDeref)
                        
                        properties.forEach({ (key, value) in
                            modelDeref.setValue(value, forKey: key)
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
                    
                    try realm.write {
                        realm.delete(modelDeref)
                    }
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
