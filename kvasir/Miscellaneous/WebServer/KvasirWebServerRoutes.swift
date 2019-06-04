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
    
    var verb: String {
        switch self {
        case .get:
            return "GET"
        }
    }
}

enum KvasirWebServerPath: KvasirWebServerPathable {
    case test
    case export
    
    var path: String {
        switch self {
        case .test:
            return "/test"
        case .export:
            return "/export"
        }
    }
}
