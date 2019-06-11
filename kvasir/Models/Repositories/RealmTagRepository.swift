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
    typealias Model = RealmTag
    
    static let shared: RealmTagRepository = {
        let repo = RealmTagRepository()
        return repo
    }()
    private init() {}
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
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
    
    func updateTagToDigestRelation(tagId: String, digestIds: [String], completion: @escaping RealmUpdateCompletion) {
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    
                    // find the tag
                    let _tag = realm.object(ofType: RealmTag.self, forPrimaryKey: tagId)
                    guard let tag = _tag else {
                        completion(false)
                        return
                    }
                    
                    // find digest operating
                    let digestOperating = realm.objects(RealmWordDigest.self).filter("\(RealmWordDigest.primaryKey()!) IN %@", digestIds)
                    
                    try realm.write {
                        for digest in digestOperating {
                            // Remove digest if exists in tag before
                            // Add digest if not exists in tag before
                            if let index = tag.wordDigests.index(of: digest) {
                                tag.wordDigests.remove(at: index)
                            } else {
                                tag.wordDigests.append(digest)
                            }
                        }
                    }
                    completion(true)
                } catch {
                    completion(false)
                }
            })
        }
    }
}
