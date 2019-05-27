//
//  AppDelegate+RealmConfig.swift
//  kvasir
//
//  Created by Monsoir on 4/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

extension AppDelegate {
    func setDefaultRealm() {
//        var config = Realm.Configuration(
//            schemaVersion: 0,
//            migrationBlock: { (migration, oldSchemaVersion) in
//                if (oldSchemaVersion < 1) {}
//            }
//        )
        var config = Realm.Configuration()
        // Use the default directory, but replace the filename with the username
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("kvasir.realm")
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setupInitialTagsIfNeeded(completion: @escaping RealmCreateCompletion) {
        guard !didTagData else { return }
        
        let tagsToBeAdded: [RealmTag] = FinderTagColor.allCases.map {
            let tag = RealmTag()
            tag.id = $0.initialId
            tag.name = $0.initialName
            tag.color = $0.hexColor
            return tag
        }
        
        let tagRepository = RealmTagRepository()
        tagRepository.createMultiple(unmanagedModels: tagsToBeAdded, update: true, completion: { [weak self] success, _ in
            guard let self = self, success else { return }
            self.setDidInitTagData()
        })
    }
    
    private var didTagData: Bool {
        return UserDefaults.standard.bool(forKey: AppConstants.tagInitiatedKey)
    }
    
    private func setDidInitTagData() {
        UserDefaults.standard.set(true, forKey: AppConstants.tagInitiatedKey)
    }
}
