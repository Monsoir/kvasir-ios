//
//  RealmCommonInfo.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import RealmSwift

class RealmBasicObject: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var serverId  = ""
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    
    var updateAtReadable: String {
        get {
            return updatedAt.string(withFormat: "yyyy-MM-dd")
        }
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension RealmBasicObject {
    @objc func preSave() {}
    
    @objc func preUpdate() {}
    
    @objc func update(pairs: [String: Any], completion: @escaping RealmSaveCompletion) {
        let objectRef = ThreadSafeReference(to: self)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let realm = try Realm()
                guard let objectDeref = realm.resolve(objectRef) else {
                    completion(false)
                    return
                }
                
                try realm.write {
                    objectDeref.preUpdate()
                    pairs.forEach({ (key, value) in
                        objectDeref.setValue(value, forKey: key)
                    })
                }
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
    
    @objc func preDelete() {
    }
    
    @objc func delete(completion: @escaping RealmSaveCompletion){
        let objectRef = ThreadSafeReference(to: self)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let realm = try Realm()
                guard let objectDeref = realm.resolve(objectRef) else {
                    completion(false)
                    return
                }
                
                try realm.write {
                    objectDeref.preUpdate()
                    realm.delete(objectDeref)
                }
                completion(true)
            } catch {
                completion(false)
            }
        }
    }
}

extension RealmBasicObject {
    static func allObjects<T: RealmBasicObject>(of type: T.Type) -> Results<T>? {
        return try? Realm().objects(type.self)
    }
    
    static func allObjectsSortedByUpdatedAt<T: RealmBasicObject>(of type: T.Type) -> Results<T>? {
        return self.allObjects(of: type.self)?.sorted(byKeyPath: "updatedAt", ascending: false)
    }
    
    static func queryObjectWithPrimaryKey<T: RealmBasicObject>(of type: T.Type, key: String) -> T? {
        return try! Realm().object(ofType: type.self, forPrimaryKey: key)
    }
    
    static func objectsForPrimaryKeys<T: RealmBasicObject>(of type: T.Type, keys: [String]) -> Results<T>? {
        return self.allObjects(of: type.self)?.filter("\(T.primaryKey()!) IN %@", keys)
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

// https://github.com/realm/realm-cocoa/issues/3381#issuecomment-256243390
extension RealmBasicObject: KvasirRealmDetachable {
    func detached() -> Self {
        let detached = type(of: self).init()
        for property in objectSchema.properties {
            guard let value = value(forKey: property.name) else { continue }
            if let detachable = value as? KvasirRealmDetachable {
                detached.setValue(detachable.detached(), forKey: property.name)
            } else {
                detached.setValue(value, forKey: property.name)
            }
        }
        return detached
    }
}
