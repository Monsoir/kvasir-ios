//
//  RemoteBookCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import SwifterSwift

class RemoteBookCoordinator {
    var thumbnail: String {
        get {
            let thumbnails = payload["imagesLarge"] as? String ?? ""
            return String(thumbnails.split(separator: ",").first ?? "")
        }
        set {}
    }
    
    var title: String {
        get {
            return payload["title"] as? String ?? ""
        }
        set {}
    }
    
    var authors: String {
        get {
            let authorString = payload["author"] as? String ?? ""
            let authors = authorString.split(separator: ",").map { String($0) }
            return authors.joined(separator: "/")
        }
        set {}
    }
    
    var detail: String {
        get {
            return payload["authors"] as? String ?? ""
        }
        set {}
    }
    
    var summary: String {
        get {
            return payload["summary"] as? String ?? ""
        }
        set {}
    }
    
    var binding: String {
        get {
            return payload["binding"] as? String ?? ""
        }
        set {}
    }
    
    var isbn13: String {
        get {
            return payload["isbn"] as? String ?? ""
        }
        set {}
    }
    
    var isbn10: String {
        get {
            return payload["isbn10"] as? String ?? ""
        }
        set {}
    }
    
    var originTitle: String {
        get {
            return payload["originTitle"] as? String ?? ""
        }
        set {}
    }
    
    var pages: Int {
        get {
            return payload["pages"] as? Int ?? 0
        }
        set {}
    }
    
    var price: String {
        get {
            return payload["price"] as? String ?? ""
        }
        set {}
    }
    
    var publisher: String {
        get {
            return payload["publisher"] as? String ?? ""
        }
        set {}
    }
    
    var translators: String {
        get {
            let translatorString = payload["translator"] as? String ?? ""
            let translators = translatorString.split(separator: ",").map { String($0) }
            return translators.joined(separator: "/")
        }
        set {}
    }
    
    
    var payloadForHeader: [String: Any] {
        get {
            return [
                "thumbnail": thumbnail,
                "title": title,
                "detail": authors,
            ]
        }
        set {}
    }
    
    private var payload: [String: Any]!
    private lazy var repository = RealmBookRepository()
    init(with payload: [String: Any]) {
        self.payload = payload
    }
    
    func batchCreate(completion: @escaping RealmCreateCompletion) {
        let extractFirstImage: (_ images: String) -> String = { images in
            return String(images.split(separator: ",").first ?? "")
        }
        
        let bookToCreate = RealmBook()
        bookToCreate.isbn13 = payload["isbn13"] as? String ?? ""
        bookToCreate.isbn10 = payload["isbn10"] as? String ?? ""
        bookToCreate.name = payload["title"] as? String ?? ""
        bookToCreate.localeName = payload["localeName"] as? String ?? ""
        bookToCreate.publisher = payload["publisher"] as? String ?? ""
        bookToCreate.imageLarge = extractFirstImage(payload["imagesLarge"] as? String ?? "")
        bookToCreate.imageMedium = extractFirstImage(payload["imagesLarge"] as? String ?? "")
        
        func extractCreators<T: RealmCreator>(combinedName: String) -> [T] {
            let names = combinedName.split(separator: ",")
            let nameArray = names.map({ (ele) -> [String: String] in
                let nameWithoutSpace = ele.replacingOccurrences(of: " ", with: "")
                // 去除 "[国籍信息]"
                let nameWithoutNation = nameWithoutSpace.replacingOccurrences(of: #"^\[.*?\]"#, with: "", options: .regularExpression, range: nameWithoutSpace.range(of: nameWithoutSpace))
                return ["name": nameWithoutNation, "localeName": ""]
            })
            return nameArray.map{ T.createAnUnmanagedOneFromPayload($0) }
        }
        
        // author infos
        let authorsToCreate: [RealmAuthor] = extractCreators(combinedName: payload["author"] as? String ?? "")
        // translator infos
        let translatorsToCreate: [RealmTranslator] = extractCreators(combinedName: payload["translator"] as? String ?? "")
        
        repository.batchCreate(unmanagedBook: bookToCreate, unmanagedAuthors: authorsToCreate, unmanagedTranslators: translatorsToCreate, completion: completion)
    }
}
