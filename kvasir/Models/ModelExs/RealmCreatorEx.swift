//
//  RealmCreatorEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmCreator {
    class func createAnUnmanagedOneFromPayload<T: RealmCreator>(_ payload: [String: Any]) -> T {
        let creator = T()
        creator.name = payload["name"] as? String ?? ""
        creator.localeName = payload["localeName"] as? String ?? ""
        return creator
    }
    
    override func preCreate() {
        super.preCreate()
        name.trim()
        localeName.trim()
    }
    
    override func preUpdate() {
        super.preUpdate()
        name.trim()
        localeName.trim()
    }
}

extension RealmCreator {
    override class var toHuman: String {
        return "创意者"
    }
    
    override class var toMachine: String {
        return "creator"
    }
}

extension RealmCreator: RealmDataBackupable {
    static var backupPath: URL? {
        return AppConstants.Paths.exportingFileDirectory?.appendingPathComponent("creators.json")
    }
    
    static func createBackupOperation() -> ExportOperation? {
        guard let backupPath = self.backupPath else { return nil }
        return RealmCreatorExportOperation(path: backupPath)
    }
}

extension RealmCreator: RealmDataRecoverable {
    static var recoverPath: URL? {
        return AppConstants.Paths.importingUnzipDirectory?.appendingPathComponent("creators.json")
    }
    
    static func createRecoverOperation() -> ImportOperation? {
        guard let recoverPath = self.recoverPath else { return nil }
        return RealmCreatorImportOperation(path: recoverPath)
    }
}
