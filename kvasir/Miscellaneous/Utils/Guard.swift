//
//  Guard.swift
//  kvasir
//
//  Created by Monsoir on 5/22/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation
import AVFoundation

struct Guard {
    static func guardAVCaptureDeviceAuthorized(authorizedHandler: @escaping (() -> Void), notEnoughAuthorizationHandler: (() -> Void)?) {
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
}
