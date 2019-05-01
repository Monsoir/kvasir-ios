//
//  CreateDigestCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class CreateDigestCoordinator<Digest: RealmWordDigest>: CreateCoordinatorable {
    private lazy var repository = RealmWordRepository<Digest>()
    private(set) var entity: Digest!
    private var postInfo = PostInfo()
    
    init(entity: Digest) {
        self.entity = entity
    }
    
    func post(info: PostInfoScript) throws {
        
        let validators: [String: SimpleValidator] = [
            "content": createNotEmptyStringValidator("\(Digest.toHuman())内容")
        ]
        
        do {
            try validators.forEach({ (key, value) in
                let testee = info[key]
                do {
                    try value(testee as Any)
                } catch let e {
                    throw e
                }
            })
        } catch let e {
            throw e
        }
        
        postInfo = info as PostInfo
    }
    
    func create(completion: @escaping RealmCreateCompletion) {
        entity.content = postInfo["content"] as? String ?? ""
        entity.pageIndex = postInfo["pageIndex"] as? Int ?? -1
        
        let otherInfo = [
            "bookId": postInfo["bookId"] as? String ?? "",
        ]
        
        repository.createOne(unmanagedModel: entity, otherInfo: otherInfo) { (success) in
            completion(success)
        }
    }
}
