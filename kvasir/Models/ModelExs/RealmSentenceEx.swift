//
//  RealmSentence.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmSentence {
    override class var toHuman: String {
        return "句摘"
    }
    
    override class var toMachine: String {
        return "sentence"
    }
}

extension RealmSentence: RealmDataBackupable {
    static var backupPath: URL? {
        return AppConstants.Paths.exportingFileDirectory?.appendingPathComponent("sentences.json")
    }
    
    static func createBackupOperation() -> ExportOperation? {
        guard let backupPath = self.backupPath else { return nil }
        return RealmDigestBackupOperation<RealmSentence>(path: backupPath)
    }
}
