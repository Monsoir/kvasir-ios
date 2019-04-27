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
}
