//
//  RealmTagEx.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

extension RealmTag {
    override class var toHuman: String {
        return "标签"
    }
    
    override class var toMachine: String {
        return "tag"
    }
}

extension RealmTag: RealmDataBackupable {
    static var backupPath: URL? {
        return AppConstants.Paths.exportingFileDirectory?.appendingPathComponent("tags.json")
    }
    
    static func createBackupOperation() -> ExportOperation? {
        guard let backupPath = self.backupPath else {
            return nil
        }
        return RealmTagExportOperation(path: backupPath)
    }
}
