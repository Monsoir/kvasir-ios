//
//  CreateCreatorCoordinator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class CreateCreatorCoordinator: CreateCoordinatorable {
    private lazy var repository = RealmCreatorRepository.shared
    var entity: RealmCreator {
        return configuration["entity"] as! RealmCreator
    }
    
    private var postInfo = PostInfo()
    private let configuration: Configurable.Configuration
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    func post(info: PostInfoScript) throws {
        
        let validators: [String: SimpleValidator] = [
            "name": createNotEmptyStringValidator("\(entity.category.toHuman)名字")
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
