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
    
    func updateTagToDigestRelation<Digest: RealmWordDigest>(tagId: String, digestType: Digest.Type, digestIds: [String], completion: @escaping RealmUpdateCompletion) {
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
                    let digestOperating = realm.objects(Digest.self).filter("\(RealmWordDigest.primaryKey()!) IN %@", digestIds)
                    
                    try realm.write {
                        for digest in digestOperating {
                            // Remove digest if exists in tag before
                            // Add digest if not exists in tag before
                            switch digestType {
                            case is RealmSentence.Type:
                                if let index = tag.sentences.index(of: digest as! RealmSentence) {
                                    tag.sentences.remove(at: index)
                                } else {
                                    tag.sentences.append(digest as! RealmSentence)
                                }
                            case is RealmParagraph.Type:
                                if let index = tag.paragraphs.index(of: digest as! RealmParagraph) {
                                    tag.paragraphs.remove(at: index)
                                } else {
                                    tag.paragraphs.append(digest as! RealmParagraph)
                                }
                            default:
                                continue
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
