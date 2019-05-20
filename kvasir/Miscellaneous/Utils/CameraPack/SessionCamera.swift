//
//  SessionCamera.swift
//  kvasir
//
//  Created by Monsoir on 5/20/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import AVFoundation
import CoreMotion

enum CameraError: Error {
    case noRearCameraAvaliable
    case noCaptureSession
}

private enum CameraOrientation {
    // using head
    case up
    case down
    case left
    case right
}

private extension UIDeviceOrientation {
    var captureOrientation: AVCaptureVideoOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            // https://forums.developer.apple.com/thread/49269
            // 设备与拍摄的左右是相反的
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return .portrait
        }
    }
}

typealias CameraPrepareCompletion = (_ error: Error?) -> Void
typealias CameraCaptureCompletion = (_ image: UIImage?, _ error: Error?) -> Void

class SessionCamera: NSObject {
    private var captureSession: AVCaptureSession?
    
    // Devices
    private var frontCamera: AVCaptureDevice? // 前置摄像头，这里只是占位，只会用到后置摄像头
    private var rearCamera: AVCaptureDevice? // 后置摄像头
    
    // Inputs
    
    private var frontCameraInput: AVCaptureDeviceInput?
    private var rearCameraInput: AVCaptureDeviceInput?
    
    // Outputs
    private var photoOutput: AVCapturePhotoOutput?
    
    private var captureCompletion: CameraCaptureCompletion?
    
    // 用于检测屏幕旋转，黑科技，用户锁定屏幕后也能生效
    private lazy var motionDetecter: CMMotionManager = {
        let manager = CMMotionManager()
        manager.deviceMotionUpdateInterval = 0.2
        return manager
    }()
    private var orientation: CameraOrientation = .up
    
    deinit {
        debugPrint("\(self) deinit")
    }
    
    /// 准备一切拍摄工作，完成后开始捕捉
    func prepare(completion: CameraPrepareCompletion?) {
        GlobalDefaultDispatchQueue.async {
            self.createCaptureSession()
            do {
                try self.configureCaptureDevice()
                try self.configureCaptureInput()
                try self.configureCaptureOutput()
                try self.requestCaptureSessionStart()
            } catch {
                completion?(error)
                return
            }
            
            MainQueue.async {
                completion?(nil)
            }
        }
    }
    
    /// 配置预览层
    func previewOn(view: UIView) {
        guard let session = captureSession else { return }
        
        MainQueue.async {
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            if previewLayer.connection?.isVideoOrientationSupported ?? false {
//                previewLayer.connection?.videoOrientation = UIDevice.current.orientation.captureOrientation
                previewLayer.connection?.videoOrientation = .portrait
            }
            
            view.layer.insertSublayer(previewLayer, at: 0)
            previewLayer.frame = view.frame
        }
    }
    
    func captureImage(completion: CameraCaptureCompletion?) {
        captureCompletion = completion
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    /// 创建 session
    private func createCaptureSession() {
        captureSession = AVCaptureSession()
    }
    
    /// 配置输入设备
    private func configureCaptureDevice() throws {
        let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let cameras = session.devices.compactMap({ $0 })
        guard !cameras.isEmpty else {
            throw CameraError.noRearCameraAvaliable
        }
        
        for camera in cameras {
            if camera.position == .back {
                rearCamera = camera
                
                try rearCamera?.lockForConfiguration()
//                rearCamera?.focusMode = .autoFocus // 自动对焦一时爽
                rearCamera?.focusMode = .continuousAutoFocus // 一直自动对焦一直爽
                rearCamera?.unlockForConfiguration()
            }
        }
    }
    
    /// 配置输入源
    private func configureCaptureInput() throws {
        guard let session = captureSession else {
            throw CameraError.noCaptureSession
        }
        
        guard let rearCamera = rearCamera else {
            throw CameraError.noRearCameraAvaliable
        }
        
        rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        if session.canAddInput(rearCameraInput!) {
            session.addInput(rearCameraInput!)
        }
    }
    
    /// 配置输出源
    private func configureCaptureOutput() throws {
        guard let session = captureSession else {
            throw CameraError.noCaptureSession
        }
        
        photoOutput = AVCapturePhotoOutput()
        photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
        
        
        if session.canAddOutput(photoOutput!) {
            session.addOutput(photoOutput!)
        }
    }
    
    
    /// 开启捕捉进行时
    func requestCaptureSessionStart() throws {
        guard let session = captureSession else {
            throw CameraError.noCaptureSession
        }
        if !session.isRunning {
            session.startRunning()
            motionDetecter.startDeviceMotionUpdates(to: OperationQueue.main) {[weak self] (data, error) in
                if let _ = error {
                    return
                }
                
                if let data = data, let self = self {
                    if fabs(data.gravity.x) > fabs(data.gravity.y) {
                        // landscape
                        self.orientation = data.gravity.x >= 0 ? .right : .left
                    } else {
                        self.orientation = data.gravity.y >= 0 ? .down : .up
                    }
                }
            }
        }
    }
    
    /// 停止捕捉
    func requestCaptureSessionStop() throws {
        guard let session = captureSession else {
            throw CameraError.noCaptureSession
        }
        if session.isRunning {
            session.stopRunning()
        }
    }
}

extension SessionCamera: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            captureCompletion?(nil, error)
            return
        }
        
        func handleImage(_ image: UIImage?) {
            MainQueue.async {
                self.captureCompletion?(image, nil)
            }
        }
        
        if let imageRepresentation = photo.cgImageRepresentation() {
            // https://stackoverflow.com/a/29049072/5211544
            let image = UIImage(cgImage: imageRepresentation.takeUnretainedValue())
//            print(Thread.current) // main queue, main thread
            handleImage(image.fixProtraitOrientation(to: orientation))
        } else if let dataRepresentation = photo.fileDataRepresentation() {
            debugPrint("A Core Graphics image representation of the captured photo, or nil if the image cannot be converted")
            let image = UIImage(data: dataRepresentation)
            handleImage(image)
        } else {
            debugPrint("Data appropriate for writing to a file of the type specified when requesting photo capture, or nil if the photo and attachment data cannot be flattened.")
        }
    }
}

private extension UIImage {
    func fixProtraitOrientation(to orientation: CameraOrientation) -> UIImage? {
        guard let cgImage = cgImage else { return nil }
        var targetOrientation = UIImage.Orientation.up
        switch orientation {
        case .up:
            targetOrientation = .right
        case .down:
            targetOrientation = .left
        case .left:
            targetOrientation = .up
        case .right:
            targetOrientation = .down
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: targetOrientation)
    }
}
