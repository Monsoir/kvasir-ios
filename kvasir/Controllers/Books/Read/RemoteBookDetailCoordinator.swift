//
//  RemoteBookCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import SwifterSwift

class RemoteBookDetailCoordinator: BookDetailCoordinator {
    override var thumbnail: String {
        let thumbnails = payload["imagesLarge"] as? String ?? ""
        return String(thumbnails.split(separator: ",").first ?? "")
    }
    
    override var title: String {
        return payload["title"] as? String ?? ""
    }
    
    override var authors: String {
        let authorString = payload["author"] as? String ?? ""
        let authors = authorString.split(separator: ",").map { String($0) }
        return authors.joined(separator: "/")
    }
    
    override var detail: String {
        return payload["authors"] as? String ?? ""
    }
    
    override var summary: String {
        return payload["summary"] as? String ?? ""
    }
    
    override var binding: String {
        return payload["binding"] as? String ?? ""
    }
    
    override var isbn13: String {
        return payload["isbn"] as? String ?? ""
    }
    
    override var isbn10: String {
        return payload["isbn10"] as? String ?? ""
    }
    
    override var originTitle: String {
        return payload["originTitle"] as? String ?? ""
    }
    
    override var pages: Int {
        return payload["pages"] as? Int ?? 0
    }
    
    override var price: String {
        return payload["price"] as? String ?? ""
    }
    
    override var publisher: String {
        return payload["publisher"] as? String ?? ""
    }
    
    override var translators: String {
        let translatorString = payload["translator"] as? String ?? ""
        let translators = translatorString.split(separator: ",").map { String($0) }
        return translators.joined(separator: "/")
    }
    
     override var payloadForHeader: [String: Any] {
        return [
            "thumbnail": thumbnail,
            "title": title,
            "detail": authors,
        ]
    }
    
    private lazy var repository = RealmBookRepository()
    
    func batchCreate(completion: @escaping RealmCreateCompletion) {
        let extractFirstImage: (_ images: String) -> String = { images in
            return String(images.split(separator: ",").first ?? "")
        }
        
        let bookToCreate = RealmBook()
        bookToCreate.isbn13 = payload["isbn13"] as? String ?? ""
        bookToCreate.isbn10 = payload["isbn10"] as? String ?? ""
        bookToCreate.name = payload["title"] as? String ?? ""
        bookToCreate.localeName = payload["localeName"] as? String ?? ""
        bookToCreate.summary = payload["summary"] as? String ?? ""
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
