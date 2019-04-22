//
//  ParagraphDataAccessor.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class ParagraphDataAccessor: WordDigestAccessor {
    override class var label: String {
        get {
            return "段落"
        }
    }
    
    override class var type: DigestType {
        get {
            return .paragraph
        }
    }
    
    func datas() -> Results<RealmParagraph>? {
        return RealmParagraph.allObjectsSortedByUpdatedAt()
    }
}
