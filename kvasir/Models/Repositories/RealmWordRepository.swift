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
    
    func preCreate(unmanagedModel: Model) {
        unmanagedModel.content.trim()
    }
    
    func createOne(unmanagedModel: T, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(unmanagedModel)
                        
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
                    }
                    
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func preUpdate(managedModel: Model) {
        managedModel.content.trim()
        managedModel.updatedAt = Date()
    }
}
