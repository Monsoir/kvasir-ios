//
//  Bartendar.swift
//  kvasir
//
//  Created by Monsoir on 4/28/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

enum SystemDirectories {
    case document
    case caches
    case library
    case tmp
    
    var url: URL? {
        switch self {
        case .document:
            return try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .library:
            return try? FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .caches:
            return try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        case .tmp:
            return FileManager.default.temporaryDirectory
        }
    }
}

struct Bartendar {
    static func handleSimpleAlert(title: String = "", message: String?, on viewController: UIViewController?, afterConfirm: (() -> Void)? = nil) {
        MainQueue.async {
            var alert: UIAlertController
            if let afterConfirm = afterConfirm {
                alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.view.tintColor = .black
                let confirmAction = UIAlertAction(title: "确定", style: .cancel, handler: { (_) in
                    afterConfirm()
                })
                alert.addAction(confirmAction)
            } else {
                alert = UIAlertController(title: title, message: message, defaultActionButtonTitle: "确定", tintColor: .black)
            }
            let host = viewController ?? {
                let rootVC = UIApplication.shared.keyWindow?.rootViewController
                guard let presentedVC = rootVC?.presentedViewController else { return rootVC! }
                return presentedVC
                }()
            host.present(alert, animated: true, completion: nil)
        }
    }
    
    static func handleTipAlert(message: String, on viewController: UIViewController?, afterConfirm: (() -> Void)? = nil) {
        self.handleSimpleAlert(title: "提示", message: message, on: viewController, afterConfirm: afterConfirm)
    }
    
    static func handleSorryAlert(message: String = "发生未知错误", on viewController: UIViewController?, afterConfirm: (() -> Void)? = nil) {
        self.handleSimpleAlert(title: "抱歉", message: message, on: viewController, afterConfirm: afterConfirm)
    }
    
    static func debugPrint(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        #if DEBUG
        print(items, separator, terminator)
        #endif
    }
}
