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
        entity.isbn = postInfo["isbn"] as? String ?? ""
        entity.publisher = postInfo["publisher"] as? String ?? ""
        
        repository.createOne(unmanagedModel: entity, otherInfo: postInfo) { (success) in
            completion(success)
        }
    }
}
