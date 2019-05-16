//
//  CreateCreatorCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class CreateCreatorCoordinator<Creator: RealmCreator>: CreateCoordinatorable {
    private lazy var repository = RealmCreatorRepository<Creator>()
    private(set) var entity: Creator!
    private var postInfo = PostInfo()
    
    init(entity: Creator) {
        self.entity = entity
    }
    
    func post(info: PostInfoScript) throws {
        
        let validators: [String: SimpleValidator] = [
            "name": createNotEmptyStringValidator("\(Creator.toHuman())名字")
        ]
        
        do {
            try validators.forEach { (key, value) in
                let testee = info[key]
                do {
                    try value(testee as Any)
                } catch let e {
                    throw e
                }
            }
        } catch let e {
            throw e
        }
        
        postInfo = info as PostInfo
    }
    
    func create(completion: @escaping RealmCreateCompletion) {
        entity.name = postInfo["name"] as? String ?? ""
        entity.localeName = postInfo["localeName"] as? String ?? ""
        
        repository.createOne(unmanagedModel: entity, otherInfo: nil) { (success, message) in
            completion(success, message)
        }
    }
}
