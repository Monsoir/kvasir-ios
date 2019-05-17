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
                    completion(true, nil)
                } catch {
                    completion(false, nil)
                }
            })
        }
    }
    
    func queryByCreatorId(_ id: String, creatorType: RealmCreator.Type, completion: @escaping RealmQueryResultsCompletion<Model>) {
        RealmReadingQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    let object = realm.object(ofType: creatorType.self, forPrimaryKey: id)
                    
                    var _entities: List<RealmBook>? = nil
                    switch creatorType {
                    case is RealmAuthor.Type:
                        _entities = (object as? RealmAuthor)?.books
                    case is RealmTranslator.Type:
                        _entities = (object as? RealmTranslator)?.books
                    default:
                        break
                    }
                    guard let entities = _entities else {
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
    
    func batchCreate(unmanagedBook: RealmBook, unmanagedAuthors: [RealmAuthor], unmanagedTranslators: [RealmTranslator], completion: @escaping RealmCreateCompletion) {
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
                    
                    
                    if let _ = realm.objects(Model.self).filter(searchBookConditions.joined(separator: " OR ")).first {
                        // book existed, just return home
                        completion(true, "书籍已存在")
                        return
                    }
                    
                    // book not existed, then create
                    let bookToCreate = unmanagedBook
                    
                    func operatingCreatorsFromInfo<creator: RealmCreator>(_ unmanagedCreators: [creator], type: creator.Type) -> (existedCreator: Results<creator>, toCreate: [creator]) {
                        // put all creator names into a set, for dedup purpose later.
                        let nameSet = Set(unmanagedCreators.map{ $0.name }).filter{ !$0.isEmpty }
                        
                        // construct filter string components
                        // find out the existed creator, won't create them again
                        let searchConditions: [String] = nameSet.map{ "name = '\($0)'" } // 字符串形式的断言，记得要加单引号
                        if searchConditions.count <= 0 {
                            // no components means no creator
                            return (
                                // workaround to create an empty Results<Type>
                                realm.objects(creator.self).filter(NSPredicate(value: false)),
                                []
                            )
                        }
                        
                        let existedCreators = realm.objects(creator.self).filter(searchConditions.joined(separator: " OR "))
                        
                        // use set to dedup, and now get the creator needed to be created
                        let existedCreatorNameSet = Set(existedCreators.map{ $0.name })
                        let namesOfCreatorToCreate = nameSet.subtracting(existedCreatorNameSet)
                        
                        let creatorsToCreate = namesOfCreatorToCreate.map({ (ele) -> creator in
                            let creator = unmanagedCreators.first(where: { $0.name == ele })!
                            creator.preCreate()
                            return creator
                        })
                        
                        return (existedCreators, creatorsToCreate)
                    }
                    // create authors
                    let (existedAuthors, authorsToCreate) = operatingCreatorsFromInfo(unmanagedAuthors, type: RealmAuthor.self)
                    
                    
                    // create translators
                    let (existedTranslators, translatorsToCreate) = operatingCreatorsFromInfo(unmanagedTranslators, type: RealmTranslator.self)
                    
                    try realm.write {
                        realm.add(bookToCreate)
                        realm.add(authorsToCreate)
                        realm.add(translatorsToCreate)
                        
                        (existedAuthors + authorsToCreate).forEach({ (ele) in
                            // workaround: 不知怎的，这里会重复添加，即一个作者会有两个相同的书籍
                            if !ele.books.contains(bookToCreate) {
                                ele.books.append(bookToCreate)
                            }
                        })

                        (existedTranslators + translatorsToCreate).forEach({ (ele) in
                            if !ele.books.contains(bookToCreate) {
                                ele.books.append(bookToCreate)
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
