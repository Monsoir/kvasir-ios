//
//  AppDelegate+RealmConfig.swift
//  kvasir
//
//  Created by Monsoir on 4/18/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

let RealmConfig = Realm.Configuration(fileURL: AppConstants.Paths.databaseFile)

extension AppDelegate {
    func setDefaultRealm() -> Bool {        
        guard Bartendar.Guard.directoryExists(directory: AppConstants.Paths.databaseFile?.deletingLastPathComponent()) else {
            return false
        }
        
//        var config = Realm.Configuration(
//            schemaVersion: 0,
//            migrationBlock: { (migration, oldSchemaVersion) in
//                if (oldSchemaVersion < 1) {}
//            }
//        )

        Realm.Configuration.defaultConfiguration = RealmConfig
        return true
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
