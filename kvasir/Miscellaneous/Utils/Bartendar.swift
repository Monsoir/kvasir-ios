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
        MainQueue.async {
            let alert = UIAlertController(title: title, message: message, defaultActionButtonTitle: "确定", tintColor: .black)
            let host = viewController ?? UIApplication.shared.keyWindow?.rootViewController
            host?.present(alert, animated: true, completion: nil)
        }
    }
    
    static func handleTipAlert(message: String, on viewController: UIViewController?) {
        self.handleSimpleAlert(title: "提示", message: message, on: viewController)
    }
    
    static func handleSorryAlert(message: String = "发生未知错误", on viewController: UIViewController?) {
        self.handleSimpleAlert(title: "抱歉", message: message, on: viewController)
    }
    
    static func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        print(items, separator, terminator)
        #endif
    }
}
