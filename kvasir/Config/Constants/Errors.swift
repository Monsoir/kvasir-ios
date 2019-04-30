//
//  Errors.swift
//  kvasir
//
//  Created by Monsoir on 4/28/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

enum KvasirError: Error {
    case contentEmpty
}

struct ValidateError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}
