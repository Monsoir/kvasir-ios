//
//  RealmWordDigestEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

private let DigestTitleLength = 60

extension RealmWordDigest {
    var title: String {
        get {
            var temp = content.replacingOccurrences(of: "\n", with: " ")
            let endIndex = temp.index(temp.startIndex, offsetBy: temp.count < DigestTitleLength ? temp.count : DigestTitleLength)
            let range = temp.startIndex ..< endIndex
            temp = String(temp[range])
            return temp.trimmed
        }
    }
    
    override func preCreate() {
        super.preCreate()
        content.trim()
    }
    
    override func preUpdate() {
        super.preUpdate()
        content.trim()
    }
    
    var tagIdSet: Set<String> {
        return Set<String>(tags.map { $0.id })
    }
}

extension RealmWordDigest {
    override class var toHuman: String {
        return "文字"
    }
    
    override class var toMachine: String {
        return "word"
    }
}

extension RealmWordDigest: RealmDataBackupable {
    static var backupPath: URL? {
        return AppConstants.Paths.exportingFileDirectory?.appendingPathComponent("digests.json")
    }
    
    static func createBackupOperation() -> ExportOperation? {
        guard let backupPath = self.backupPath else { return nil }
        return RealmDigestExportOperation(path: backupPath)
    }
}

extension RealmWordDigest: RealmDataRecoverable {
    static var recoverPath: URL? {
        return AppConstants.Paths.importingUnzipDirectory?.appendingPathComponent("digests.json")
    }
    
    static func createRecoverOperation() -> ImportOperation? {
        guard let recoverPath = self.recoverPath else { return nil }
        return RealmDigestImportOperation(path: recoverPath)
    }
}

