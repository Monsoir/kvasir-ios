//
//  CreateBookCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/30/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class CreateBookCoordinator: CreateCoordinatorable {
    private lazy var repository = RealmBookRepository()
    private(set) var entity: RealmBook!
    private var postInfo = PostInfo()
    
    init(entity: RealmBook) {
        self.entity = entity
    }
    
    func post(info: PostInfoScript) throws  {
        postInfo = info as PostInfo
    }
    
    func create(completion: @escaping RealmCreateCompletion) {
        entity.name = postInfo["name"] as? String ?? ""
        entity.localeName = postInfo["localeName"] as? String ?? ""
        entity.isbn13 = postInfo["isbn13"] as? String ?? ""
        entity.isbn10 = postInfo["isbn10"] as? String ?? ""
        entity.publisher = postInfo["publisher"] as? String ?? ""
        
        repository.createOne(unmanagedModel: entity, otherInfo: postInfo) { (success, message) in
            completion(success, message)
        }
    }
    
    func queryFromRemote(isbn: String?, completion: @escaping ((Bool, [String: Any]?, String) -> Void)) {
        guard let isbn = isbn, isbn.msr.isISBN else {
            completion(false, nil, "ISBN 不符合规范")
            return
        }
        BookProxySessionManager.shared
            .request(BookProxyEndpoint.search(isbn: isbn))
            .validate(statusCode: 200..<300)
            .responseJSON(queue: GlobalDefaultDispatchQueue, options: .allowFragments, completionHandler: { (response) in
                debugPrint(response)
                
                switch response.result {
                case .success(let value):
                    let value = value as! [String: Any]
                    guard let success = value["success"] as? Bool, success else {
                        completion(false, nil, "服务出错")
                        return
                    }
                    completion(true, value["data"] as? [String : Any] ?? [:], "")
                case .failure(let error):
                    guard let code = response.response?.statusCode else {
                        completion(false, nil, "位置错误")
                        return
                    }
                    switch code {
                    case 404:
                        completion(false, nil, "请求地址出错")
                    case 500:
                        completion(false, nil, "服务出错")
                    default:
                        completion(false, nil, error.localizedDescription)
                    }
                }
            })
    }
}
