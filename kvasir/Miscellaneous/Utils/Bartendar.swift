//
//  Bartendar.swift
//  kvasir
//
//  Created by Monsoir on 4/28/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

struct Bartendar {
    static func handleSimpleAlert(title: String = "", message: String?, on viewController: UIViewController?) {
        let alert = UIAlertController(title: title, message: message, defaultActionButtonTitle: "确定", tintColor: .black)
        let host = viewController ?? UIApplication.shared.keyWindow?.rootViewController
        host?.present(alert, animated: true, completion: nil)
    }
}
