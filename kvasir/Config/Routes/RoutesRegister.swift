//
//  Routes.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

struct URLNavigaionMap {
    static func initialize(navigator: NavigatorType) {
        func registerRoute(url: KvasirURL) {
            navigator.register(url.template, url.controllerFactory)
        }
        
        KvasirURL.allCases.forEach{ registerRoute(url: $0) }
    }
}
