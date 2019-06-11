//
//  RealmBookRepository.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift
import SwifterSwift

class RealmBookRepository: Repositorable {
    typealias Model = RealmBook
    
    static let shared: RealmBookRepository = {
        let repo = RealmBookRepository()
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
    
    func createOne(unmanagedModel: Model, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                
                let authorIds = otherInfo?["authorIds"] as? [String] ?? []
                let translatorIds = otherInfo?["translatorIds"] as? [String] ?? []
                
                do {
                    let realm = try Realm()
                    
                    let authors = realm.objects(RealmCreator.self).filter("\(RealmCreator.primaryKey()!) IN %@", authorIds)
                    let translators = realm.objects(RealmCreator.self).filter("\(RealmCreator.primaryKey()!) IN %@", translatorIds)
                    
                    try realm.write {
                        realm.add(unmanagedModel)
                        
                        authors.forEach({ (ele) in
                            ele.writtenBooks.append(unmanagedModel)
                        })
                        
                        translators.forEach({ (ele) in
                            ele.translatedBooks.append(unmanagedModel)
                        })
                    }
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func queryByCreatorId(_ id: String, completion: @escaping RealmQueryResultsCompletion<Model>) {
        RealmReadingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let object = realm.object(ofType: RealmCreator.self, forPrimaryKey: id)
                    
                    guard let entities = object?.writtenBooks else {
                        completion(false, nil)
                        return
                    }
                    
                    type(of: self).switchBackToMainQueue(objects: entities.filter(NSPredicate(value: true)), okHandler: { (objects) in
                        completion(true, objects)
                    }, notOkHandler: {
                        completion(false, nil)
                    })
                    
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func preUpdate(managedModel: Model) {
        managedModel.preUpdate()
    }
    
    func batchCreate(unmanagedBook: RealmBook, unmanagedAuthors: [RealmCreator], unmanagedTranslators: [RealmCreator], completion: @escaping RealmCreateCompletion) {
        RealmWritingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    
                    // create a book
                    unmanagedBook.preCreate()
                    // if book exists
                    // isbn13, isbn10, book name
                    let searchBookConditions: [String] = {
                        var temp = [String]()
                        let isbn13 = unmanagedBook.isbn13
                        if !isbn13.isEmpty {
                            temp.append("isbn13 = '\(isbn13)'")
                        }
                        
                        let isbn10 = unmanagedBook.isbn10
                        if !isbn10.isEmpty {
                            temp.append("isbn10 = '\(isbn10)'")
                        }
                        
                        let bookName = unmanagedBook.name
                        if !bookName.isEmpty {
                            temp.append("name = '\(bookName)'")
                        }
                        return temp
                    }()
                    
                    if searchBookConditions.isEmpty {
                        completion(false, "书籍信息有误")
                        return
                    }
                    if let _ = realm.objects(Model.self).filter(searchBookConditions.joined(separator: " OR ")).first {
                        // book existed, just return home
                        completion(true, "书籍已存在")
                        return
                    }
                    
                    // book not existed, then create
                    let bookToCreate = unmanagedBook
                    
                    func operatingCreatorsFromInfo(_ unmanagedCreators: [RealmCreator]) -> (existedCreator: Results<RealmCreator>, toCreate: [RealmCreator]) {
                        // put all creator names into a set, for dedup purpose later.
                        let nameSet = Set(unmanagedCreators.map{ $0.name }).filter{ !$0.isEmpty }
                        
                        // construct filter string components
                        // find out the existed creator, won't create them again
                        let searchConditions: [String] = nameSet.map{ "name = '\($0)'" } // 字符串形式的断言，记得要加单引号
                        if searchConditions.count <= 0 {
                            // no components means no creator
                            return (
                                // workaround to create an empty Results<Type>
                                realm.objects(RealmCreator.self).filter(NSPredicate(value: false)),
                                []
                            )
                        }
                        
                        let existedCreators = realm.objects(RealmCreator.self).filter(searchConditions.joined(separator: " OR "))
                        
                        // use set to dedup, and now get the creator needed to be created
                        let existedCreatorNameSet = Set(existedCreators.map{ $0.name })
                        let namesOfCreatorToCreate = nameSet.subtracting(existedCreatorNameSet)
                        
                        let creatorsToCreate = namesOfCreatorToCreate.map({ (ele) -> RealmCreator in
                            let creator = unmanagedCreators.first(where: { $0.name == ele })!
                            creator.preCreate()
                            return creator
                        })
                        
                        return (existedCreators, creatorsToCreate)
                    }
                    // create authors
                    let (existedAuthors, authorsToCreate) = operatingCreatorsFromInfo(unmanagedAuthors)
                    
                    
                    // create translators
                    let (existedTranslators, translatorsToCreate) = operatingCreatorsFromInfo(unmanagedTranslators)
                    
                    try realm.write {
                        realm.add(bookToCreate)
                        realm.add(authorsToCreate)
                        realm.add(translatorsToCreate)
                        
                        (existedAuthors + authorsToCreate).forEach({ (ele) in
                            // workaround: 不知怎的，这里会重复添加，即一个作者会有两个相同的书籍
                            if !ele.writtenBooks.contains(bookToCreate) {
                                ele.writtenBooks.append(bookToCreate)
                            }
                        })

                        (existedTranslators + translatorsToCreate).forEach({ (ele) in
                            if !ele.translatedBooks.contains(bookToCreate) {
                                ele.translatedBooks.append(bookToCreate)
                            }
                        })
                    }
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
}
