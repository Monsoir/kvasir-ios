//
//  AppDelegate+Appearance.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

extension AppDelegate {
    func setAppTintColor() {
        UINavigationBar.appearance().tintColor = Color(hexString: ThemeConst.outlineColor)
        UIView.appearance().tintColor = Color(hexString: ThemeConst.outlineColor)
    }
}
