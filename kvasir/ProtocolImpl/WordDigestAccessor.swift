//
//  WordDigestAccessor.swift
//  kvasir
//
//  Created by Monsoir on 4/19/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import RealmSwift

class WordDigestAccessor: NSObject {
    class var label: String {
        get {
            return "Unknown"
        }
    }
    
    class var type: DigestType {
        get {
            return .sentence
        }
    }
    
    static func getAccessor(of type: DigestType) -> WordDigestAccessor {
        switch type {
        case .sentence:
            return SentenceDataAccessor()
        case .paragraph:
            return ParagraphDataAccessor()
        }
    }
    
    override init() {
        super.init()
    }
}
