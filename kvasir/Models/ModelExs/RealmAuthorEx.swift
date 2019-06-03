//
//  RealmAuthorEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmAuthor {
    class func createAnUnmanagedOneFromPayload(_ payload: [String: Any]) -> RealmCreator {
        return super.createAnUnmanagedOneFromPayload(payload)
    }
}

extension RealmAuthor {
    override class var toHuman: String {
        return "作者"
    }
    
    override class var toMachine: String {
        return "author"
    }
}

extension RealmAuthor: RealmDataBackupable {
    static var backupPath: URL? {
        return SystemDirectories.tmp.url?.appendingPathComponent("authors.json")
    }
    
    static func createBackupOperation() -> BackupOperation? {
        guard let backupPath = self.backupPath else { return nil }
        return RealmCreatorBackupOperation<RealmAuthor>(path: backupPath)
    }
}
