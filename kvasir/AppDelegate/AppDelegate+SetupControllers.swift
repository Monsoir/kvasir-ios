//
//  AppDelegate+SetupControllers.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension AppDelegate {
    func setupControllers() -> UIViewController {
        let vc = TopListViewController()
        let nc = UINavigationController(rootViewController: vc)
        return nc
    }
}
