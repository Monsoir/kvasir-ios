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
        let thumbnails = remoteData?["imagesLarge"] as? String ?? ""
        return String(thumbnails.split(separator: ",").first ?? "")
    }
    
    override var title: String {
        return remoteData?["title"] as? String ?? ""
    }
    
    override var authors: String {
        let authorString = remoteData?["author"] as? String ?? ""
        let authors = authorString.split(separator: ",").map { String($0) }
        return authors.joined(separator: "/")
    }
    
    override var detail: String {
        return remoteData?["authors"] as? String ?? ""
    }
    
    override var summary: String {
        return remoteData?["summary"] as? String ?? ""
    }
    
    override var binding: String {
        return remoteData?["binding"] as? String ?? ""
    }
    
    override var isbn13: String {
        return remoteData?["isbn"] as? String ?? ""
    }
    
    override var isbn10: String {
        return remoteData?["isbn10"] as? String ?? ""
    }
    
    override var originTitle: String {
        return remoteData?["originTitle"] as? String ?? ""
    }
    
    override var pages: Int {
        return remoteData?["pages"] as? Int ?? 0
    }
    
    override var price: String {
        return remoteData?["price"] as? String ?? ""
    }
    
    override var publisher: String {
        return remoteData?["publisher"] as? String ?? ""
    }
    
    override var translators: String {
        let translatorString = remoteData?["translator"] as? String ?? ""
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
    private var remoteData: [String: Any]?
    
    func batchCreate(completion: @escaping RealmCreateCompletion) {
        guard let remoteData = remoteData else {
            completion(false, "信息有误")
            return
        }
        let extractFirstImage: (_ images: String) -> String = { images in
            return String(images.split(separator: ",").first ?? "")
        }
        
        let bookToCreate = RealmBook()
        bookToCreate.isbn13 = remoteData["isbn"] as? String ?? ""
        bookToCreate.isbn10 = remoteData["isbn10"] as? String ?? ""
        bookToCreate.name = remoteData["title"] as? String ?? ""
        bookToCreate.localeName = remoteData["localeName"] as? String ?? ""
        bookToCreate.summary = remoteData["summary"] as? String ?? ""
        bookToCreate.publisher = remoteData["publisher"] as? String ?? ""
        bookToCreate.imageLarge = extractFirstImage(remoteData["imagesLarge"] as? String ?? "")
        bookToCreate.imageMedium = extractFirstImage(remoteData["imagesLarge"] as? String ?? "")
        
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
        let authorsToCreate: [RealmAuthor] = extractCreators(combinedName: remoteData["author"] as? String ?? "")
        // translator infos
        let translatorsToCreate: [RealmTranslator] = extractCreators(combinedName: remoteData["translator"] as? String ?? "")
        
        repository.batchCreate(unmanagedBook: bookToCreate, unmanagedAuthors: authorsToCreate, unmanagedTranslators: translatorsToCreate, completion: completion)
    }
    
    override func query(_ completion: @escaping BookDetailQueryCompletion) {
        guard let code = configuraion["code"] as? String else { return }
        
        ProxySessionManager.shared
            .request(BookProxyEndpoint.search(isbn: code))
            .validate(statusCode: 200..<300)
            .responseJSON(queue: GlobalDefaultDispatchQueue, options: .allowFragments, completionHandler: { [weak self] (response) in
                guard let data = ProxySessionManager.handleResponse(response), let strongSelf = self else {
                    completion(false, nil, nil)
                    return
                }
                strongSelf.remoteData = data
                completion(true, nil, nil)
            })
    }
}
