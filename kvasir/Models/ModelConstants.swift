//
//  Constants.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

enum DigestType {
    case sentence
    case paragraph
    
    var toMachine: String {
        get {
            switch self {
            case .sentence:
                return "sentence"
            case .paragraph:
                return "paragraph"
            }
        }
    }
    
    var toHuman: String {
        get {
            switch self {
            case .sentence:
                return "句子"
            case .paragraph:
                return "段落"
            }
        }
    }
}
