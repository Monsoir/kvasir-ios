//
//  RealmParagraph.swift
//  kvasir
//
//  Created by Monsoir on 5/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

extension RealmParagraph {
    override class var toHuman: String {
        return "段摘"
    }
    
    override class var toMachine: String {
        return "paragraph"
    }
}

extension RealmParagraph: RealmDataBackupable {
    static var backupPath: URL? {
        return SystemDirectories.tmp.url?.appendingPathComponent("paragraphs.json")
    }
    
    static func createBackupOperation() -> BackupOperation? {
        guard let backupPath = self.backupPath else { return nil }
        return RealmDigestBackupOperation<RealmParagraph>(path: backupPath)
    }
}
