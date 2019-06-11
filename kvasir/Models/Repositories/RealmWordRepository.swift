//
//  RealmWordRepository.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift
import SwifterSwift

class RealmWordRepository: Repositorable {
    typealias Model = RealmWordDigest
    
    static let shared: RealmWordRepository = {
        let repo = RealmWordRepository()
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
    
    func preUpdate(managedModel: Model) {
        managedModel.preUpdate()
    }
    
    func createOne(unmanagedModel: Model, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(unmanagedModel)
                        
                        // 链接对应书籍
                        if let bookId = otherInfo?["bookId"] as? String, !bookId.isEmpty {
                            if let book = realm.object(ofType: RealmBook.self, forPrimaryKey: bookId) {
                                book.digests.append(unmanagedModel)
                                unmanagedModel.book = book
                            }
                        }
                        
                        // 链接对应标签
                        if let tagIds = otherInfo?["tagIds"] as? [String], !tagIds.isEmpty {
                            // 找出要关联的标签
                            let tagsToAssociate = realm.objects(RealmTag.self).filter({ (tag) -> Bool in
                                return tagIds.contains(tag.id)
                            })
                            tagsToAssociate.forEach({ (ele) in
                                if !ele.wordDigests.contains(unmanagedModel) {
                                    ele.wordDigests.append(unmanagedModel)
                                }
                            })
                        }
                    }
                    
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
//    func queryBy(content: String, sortedByUpdated: Bool = true, completion: @escaping RealmQueryResultsCompletion<Model>) {
//        RealmReadingQueue.async {
//            autoreleasepool(invoking: { () -> Void in
//                do {
//                    let realm = try Realm()
//                    let filteringPredicate = "content CONTAINS[c] '\(content)'"
//                    let objects = realm.objects(Model.self).filter(filteringPredicate).sorted(byKeyPath: "updatedAt", ascending: !sortedByUpdated)
//                    type(of: self).switchBackToMainQueue(objects: objects, okHandler: { (objectsDeref) in
//                        completion(true, objectsDeref)
//                    }, notOkHandler: {
//                        completion(false, nil)
//                    })
//                } catch {
//                    completion(false, nil)
//                }
//            })
//        }
//    }
}
