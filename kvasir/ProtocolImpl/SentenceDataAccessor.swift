//
//  SentenceDataAccessor.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class SentenceDataAccessor: WordDigestAccessor {
    override class var label: String {
        get {
            return "句子"
        }
    }
    
    override class var type: DigestType {
        get {
            return .sentence
        }
    }
    
    func datas() -> Results<RealmSentence>? {
        return RealmSentence.allObjectsSortedByUpdatedAt()
    }
}

