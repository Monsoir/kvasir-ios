//
//  KvasirWebServerRoutes.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

enum KvasirWebServerVerb: KvasirWebServerVerbable {
    case get
    case post
    case options
    
    var verb: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .options:
            return "OPTIONS"
        }
    }
}

enum KvasirWebServerPath: KvasirWebServerPathable {
    case test
    case export
    case `import`
    
    var path: String {
        switch self {
        case .test:
            return "/test"
        case .export:
            return "/export"
        case .import:
            return "/import"
        }
    }
}
