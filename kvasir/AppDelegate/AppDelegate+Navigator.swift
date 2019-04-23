//
//  AppDelegate+Navigator.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import URLNavigator

let KvasirNavigator = Navigator()
extension AppDelegate {
    func setupNavigator() {
        URLNavigaionMap.initialize(navigator: KvasirNavigator)
    }
}
