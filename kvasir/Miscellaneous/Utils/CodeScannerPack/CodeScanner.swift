//
//  CodeScanner.swift
//  kvasir
//
//  Created by Monsoir on 5/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import AVFoundation

enum CodeScanType {
    case bar
    case qr
    case both
}

private let BarCodeTypes: [AVMetadataObject.ObjectType] = [.code128, .code39, .code39Mod43, .code93, .ean13, .ean8, .interleaved2of5, .itf14, .pdf417, .upce]
private let QRCodeTypes: [AVMetadataObject.ObjectType] = [.qr]
private let AllCodeTypes: [AVMetadataObject.ObjectType] = BarCodeTypes + QRCodeTypes
typealias CodeScannerCompletion = (_ success: Bool, _ code: String) -> Void
class CodeScanner: NSObject {
    private var captureSession: AVCaptureSession?
    private var completion: CodeScannerCompletion?
    private var interestRect: CGRect?
    private var codeType: CodeScanType
    private var input: AVCaptureInput?
    private var output: AVCaptureMetadataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    private var metaObjectTypes: [AVMetadataObject.ObjectType] {
        get {
            switch codeType {
            case .bar:
                return BarCodeTypes
            case .qr:
                return QRCodeTypes
            case .both:
                return AllCodeTypes
            }
        }
    }
    
    init(codeType type: CodeScanType, interestRect rect: CGRect?, completion: @escaping CodeScannerCompletion) {
        self.codeType = type
        self.interestRect = rect
        self.completion = completion
        super.init()
        
        setupNotification()
    }
    
    deinit {
        clearupNotification()
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    func requestCaptureSessionStart(completion: (() -> Void)?) {
        guard let session = captureSession else { return }
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func requestCaptureSessionStop(completion: (() -> Void)?) {
        guard let session = captureSession else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func requestSetupSession(previewOn view: UIView, notEnoughAuthorizationHandler: (() -> Void)?) {
        func setupSession() {
            if let session = createCaptureSession(previewOn: view) {
                captureSession = session
                MainQueue.async { [weak self] in
                    guard let strongSelf = self else { return }
                    let pl = strongSelf.createPreviewLayer(withCaptureSession: session, view: view)
                    view.layer.insertSublayer(pl, at: 0)
                    strongSelf.previewLayer = pl
                }
            }
        }
        type(of: self).canCaptureVideo(authorizedHandler: {
            setupSession()
        }) {
            notEnoughAuthorizationHandler?()
        }
    }
    
    private func createCaptureSession(previewOn view: UIView) -> AVCaptureSession? {
        // Session as a coordinator
        let session = AVCaptureSession()
        
        // Get hardware
        guard let device = AVCaptureDevice.default(for: .video) else {
            Bartendar.debugPrint("Failed to init an av capture device\n\(Thread.callStackSymbols)")
            return nil
        }
        
        session.beginConfiguration()
        do {
            // Add input source to session
            let deviceInput = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(deviceInput) else {
                Bartendar.debugPrint("Device input can not be added to capture session\n\(Thread.callStackSymbols)")
                return nil
            }
            session.addInput(deviceInput)
            input = deviceInput
            
            // Add output to session
            // - output decides what result will be generated based on images captured
            let metaDataOutput = AVCaptureMetadataOutput()
            guard session.canAddOutput(metaDataOutput) else {
                Bartendar.debugPrint("Meta data output can not be added to capture session\n\(Thread.callStackSymbols)")
                return nil
            }
            session.addOutput(metaDataOutput)
            output = metaDataOutput
            
            // - set ouput delegate, deliver result to user
            metaDataOutput.setMetadataObjectsDelegate(self, queue: GlobalUserInitiatedDispatchQueue)
            
            // - set what types of code should be tested to recognize
            let allTypes = Set(metaDataOutput.availableMetadataObjectTypes)
            let filtered = metaObjectTypes.filter { (mediaType) -> Bool in
                allTypes.contains(mediaType)
            }
            metaDataOutput.metadataObjectTypes = filtered
        } catch {
            Bartendar.debugPrint("Exception thrown when creating input and output for av capture device\n\(Thread.callStackSymbols)")
            return nil
        }
        
        session.commitConfiguration()
        return session
    }
    
    private func createPreviewLayer(withCaptureSession captureSession: AVCaptureSession, view: UIView) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    private func checkAuthorization() -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        return status == .authorized
    }
}

private extension CodeScanner {
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeRectOfInterests), name: NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange, object: nil)
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.requestCaptureSessionStart(completion: nil)
        }
        NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: OperationQueue.main) { [weak self] (_) in
            guard let strongSelf = self else { return }
            strongSelf.requestCaptureSessionStop(completion: nil)
        }
    }
    
    func clearupNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func changeRectOfInterests(notif: Notification) {
        // - set rect of captured images to focus
        // https://www.jianshu.com/p/8bb3d8cb224e
        
        // notif:
        // name = AVCaptureInputPortFormatDescriptionDidChangeNotification,
        // object = Optional(<AVCaptureInputPort: 0x282537dc0 (AVCaptureDeviceInput: 0x282766da0) vide 420v enabled>),
        // userInfo = nil
        guard let myInput = input, (notif.object as? AVCaptureInput.Port)?.input == myInput else { return }
        if let rect = interestRect, let previewLayer = previewLayer {
            output?.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: rect)
        }
    }
}

extension CodeScanner: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 扫描结果
        // <AVMetadataMachineReadableCodeObject: 0x2829c1f60, type="org.gs1.EAN-13", bounds={ 0.5,0.3 0.0x0.4 }>
        // corners { 0.5,0.7 0.5,0.7 0.5,0.3 0.5,0.3 },
        // time 822407380602041,
        // stringValue "9787563394180"
        guard let metaDataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        
        requestCaptureSessionStop(completion: nil)
        completion?(true, metaDataObject.stringValue ?? "")
    }
}

extension CodeScanner {
    static func triggerFlashlight(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasFlash && device.hasTorch {
            do {
                try device.lockForConfiguration()
            } catch {
                Bartendar.handleSorryAlert(message: "闪关灯开启失败", on: nil)
            }
            device.torchMode = on ? .on : .off
            device.flashMode = on ? .on : .off
            device.unlockForConfiguration()
        }
    }
}

extension CodeScanner {
    static func canCaptureVideo(authorizedHandler: @escaping (() -> Void), notEnoughAuthorizationHandler: @escaping (() -> Void)) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            authorizedHandler()
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    authorizedHandler()
                } else {
                    notEnoughAuthorizationHandler()
                }
            }
        case .denied: // The user has previously denied access.
            notEnoughAuthorizationHandler()
            return
        case .restricted: // The user can't grant access due to restrictions.
            notEnoughAuthorizationHandler()
            return
        }
    }
}
