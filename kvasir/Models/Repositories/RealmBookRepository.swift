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
        unmanagedModel.name.trim()
        unmanagedModel.localeName.trim()
        unmanagedModel.isbn13.trim()
        unmanagedModel.isbn10.trim()
        unmanagedModel.publisher.trim()
    }
    
    func createOne(unmanagedModel: Model, otherInfo: RealmCreateInfo?, completion: @escaping RealmCreateCompletion) {
        preCreate(unmanagedModel: unmanagedModel)
        GlobalUserInitiatedDispatchQueue.async {
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
        GlobalUserInitiatedDispatchQueue.async {
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
        managedModel.name.trim()
        managedModel.localeName.trim()
        managedModel.isbn13.trim()
        managedModel.isbn10.trim()
        managedModel.publisher.trim()
        managedModel.updatedAt = Date()
    }
    
    func batchCreate(bookInfo: RealmCreateInfo, authorInfos: [RealmCreateInfo], translatorInfos: [RealmCreateInfo], completion: @escaping RealmCreateCompletion) {
        GlobalUserInitiatedDispatchQueue.async {
            autoreleasepool(invoking: { () -> Void in
                do {
                    let realm = try Realm()
                    
                    // create a book
                    
                    // if book exists
                    // isbn13, isbn10, book name
                    let searchBookConditions: [String] = {
                        var temp = [String]()
                        if let isbn13 = bookInfo["isbn13"] {
                            temp.append("isbn13 = '\(isbn13)'")
                        }
                        
                        if let isbn10 = bookInfo["isbn10"] {
                            temp.append("isbn10 = '\(isbn10)'")
                        }
                        
                        if let bookName = bookInfo["name"] {
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
                    let bookToCreate = RealmBook()
                    bookToCreate.isbn13 = bookInfo["isbn13"] as? String ?? ""
                    bookToCreate.isbn10 = bookInfo["isbn10"] as? String ?? ""
                    bookToCreate.name = bookInfo["name"] as? String ?? ""
                    bookToCreate.localeName = bookInfo["localeName"] as? String ?? ""
                    bookToCreate.publisher = bookInfo["publisher"] as? String ?? ""
                    bookToCreate.imageLarge = bookInfo["imageLarge"] as? String ?? ""
                    bookToCreate.imageMedium = bookInfo["imageMedium"] as? String ?? ""
                    
                    func operatingCreatorsFromInfo<creator: RealmCreator>(_ infos: [RealmCreateInfo], type: creator.Type) -> (existedCreator: Results<creator>, toCreate: [creator]) {
                        let nameSet = Set(infos.map{ $0["name"] as? String ?? "" }).filter{ !$0.isEmpty }
                        let searchConditions: [String] = nameSet.map{ "name = '\($0)'" } // 字符串形式的断言，记得要加单引号
                        if searchConditions.count <= 0 {
                            return (
                                // workaround to create an empty Results<Type>
                                realm.objects(creator.self).filter(NSPredicate(value: false)),
                                []
                            )
                        }
                        let existedCreators = realm.objects(creator.self).filter(searchConditions.joined(separator: " OR "))
                        let infosOfCreatorToCreate: [RealmCreateInfo] = {
                            // use set to dedup
                            let existedCreatorNameSet = Set(existedCreators.map{ $0.name })
                            let namesOfCreatorToCreate = nameSet.subtracting(existedCreatorNameSet)
                            
                            return namesOfCreatorToCreate.map({ (ele) -> RealmCreateInfo in
                                return infos.first(where: { $0["name"] as? String ?? "" == ele })!
                            })
                        }()
                        let creatorsToCreate: [creator] = infosOfCreatorToCreate.map {
                            let c = creator()
                            c.name = $0["name"] as? String ?? ""
                            c.localeName = $0["localeName"] as? String ?? ""
                            return c
                        }
                        return (existedCreators, creatorsToCreate)
                    }
                    // create authors
                    let (existedAuthors, authorsToCreate) = operatingCreatorsFromInfo(authorInfos, type: RealmAuthor.self)
                    
                    
                    // create translators
                    let (existedTranslators, translatorsToCreate) = operatingCreatorsFromInfo(translatorInfos, type: RealmTranslator.self)
                    
                    try realm.write {
                        realm.add(bookToCreate)
                        realm.add(authorsToCreate)
                        realm.add(translatorsToCreate)
                        
                        (existedAuthors + authorsToCreate).forEach({ (ele) in
                            ele.books.append(bookToCreate)
                        })
                        
                        (existedTranslators + translatorsToCreate).forEach({ (ele) in
                            ele.books.append(bookToCreate)
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
