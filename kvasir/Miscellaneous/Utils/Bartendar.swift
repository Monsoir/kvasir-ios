//
//  Bartendar.swift
//  kvasir
//
//  Created by Monsoir on 4/28/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import AVFoundation

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
    
    struct Guard {
        static func AVCaptureDeviceAuthorized(authorizedHandler: @escaping (() -> Void), notEnoughAuthorizationHandler: (() -> Void)?) {
            // https://developer.apple.com/documentation/avfoundation/cameras_and_media_capture/requesting_authorization_for_media_capture_on_ios
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                authorizedHandler()
                
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        authorizedHandler()
                    } else {
                        guard let rejectHandler = notEnoughAuthorizationHandler else {
                            Bartendar.handleTipAlert(message: "没有足够的权限使用相机", on: nil)
                            return
                        }
                        rejectHandler()
                    }
                }
            case .denied: // The user has previously denied access.
                fallthrough
            case .restricted: // The user can't grant access due to restrictions.
                guard let rejectHandler = notEnoughAuthorizationHandler else {
                    Bartendar.handleTipAlert(message: "没有足够的权限使用相机", on: nil)
                    return
                }
                rejectHandler()
            }
        }
        
        static func directoryExists(directory: URL?) -> Bool {
            guard let directory = directory else { return false }
            return FileManager.default.msr.createDirectoryIfNotExist(directory)
        }
    }

}
