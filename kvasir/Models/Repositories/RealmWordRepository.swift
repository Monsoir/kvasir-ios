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

class RealmWordRepository<T: RealmWordDigest>: Repositorable {
    typealias Model = T
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
//    func queryAllSortingByUpdatedAtDesc(with bookId: String, completion: @escaping (Bool, Results<T>?) -> Void) {
//        guard !bookId.isEmpty else {
//            completion(false, nil)
//            return
//        }
//        RealmWritingQueue.async {
//            autoreleasepool(invoking: { () -> Void in
//                do {
//                    let realm = try Realm()
//                    let results = realm.objects(T.self).filter("book = \()")
//                } catch {
//                    completion(false, nil)
//                }
//            })
//        }
//    }
    
    func preCreate(unmanagedModel: Model) {
        unmanagedModel.preCreate()
    }
    
    func preUpdate(managedModel: Model) {
        managedModel.preUpdate()
    }
    
    func createOne(unmanagedModel: T, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
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
                                switch unmanagedModel {
                                case is RealmSentence:
                                    book.sentences.append(unmanagedModel as! RealmSentence)
                                case is RealmParagraph:
                                    book.paragraphs.append(unmanagedModel as! RealmParagraph)
                                default:
                                    break
                                }
                                
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
                                switch unmanagedModel {
                                case is RealmSentence:
                                    let s = unmanagedModel as! RealmSentence
                                    if !ele.sentences.contains(s) {
                                        ele.sentences.append(s)
                                    }
                                case is RealmParagraph:
                                    let p = unmanagedModel as! RealmParagraph
                                    if !ele.paragraphs.contains(p) {
                                        ele.paragraphs.append(p)
                                    }
                                default:
                                    break
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
    
    func queryBy(content: String, sortedByUpdated: Bool = true, completion: @escaping RealmQueryResultsCompletion<Model>) {
        RealmReadingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let filteringPredicate = "content CONTAINS[c] '\(content)'"
                    let objects = realm.objects(Model.self).filter(filteringPredicate).sorted(byKeyPath: "updatedAt", ascending: !sortedByUpdated)
                    type(of: self).switchBackToMainQueue(objects: objects, okHandler: { (objectsDeref) in
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
}
