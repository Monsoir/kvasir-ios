//
//  SessionCameraViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/20/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import CropViewController

private let CaptureButtonLength = 80 as CGFloat

protocol SessionCameraViewControllerDelegate: class {
    func didCaptureImage(_ image: UIImage)
}

class SessionCameraViewController: UIViewController {
    weak var delegate: SessionCameraViewControllerDelegate?
    
    private lazy var camera: SessionCamera = SessionCamera()
    
    private lazy var btnCapture: UIButton = {
        let btn = simpleButtonWithButtonFromAwesomefont(name: .camera)
        btn.layer.cornerRadius = CaptureButtonLength / 2
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleCapture), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnClose: UIButton = {
        let btn = simpleButtonWithButtonFromAwesomefont(name: .times)
        btn.layer.cornerRadius = CaptureButtonLength / 2
        btn.backgroundColor = .white
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        return btn
    }()
    
    override var shouldAutorotate: Bool {
        // 先禁用这个界面的屏幕旋转，减少适配的工作量
        return false
    }
    
    deinit {
        debugPrint("\(self) deinit")
    }
}

extension SessionCameraViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configurePreviewLayer()
        setupSubviews()
    }
}

extension SessionCameraViewController {
    private func configurePreviewLayer() {
        camera.prepare { [weak self] (error) in
            guard let self = self else { return }
            guard error == nil else {
                guard let error = error as? CameraError else {
                    self.dismiss(animated: true, completion: {
                        Bartendar.handleSorryAlert(message: "未知错误", on: nil)
                    })
                    return
                }
                
                var message = "未知错误"
                switch error {
                case .noCaptureSession:
                    message = "noCaptureSession"
                case .noRearCameraAvaliable:
                    message = "noRearCameraAvaliable"
                }
                
                self.dismiss(animated: true, completion: {
                    Bartendar.handleSorryAlert(message: "相机配置时出错：\(message)", on: nil)
                })
                return
            }
            
            self.camera.previewOn(view: self.view)
        }
    }
    
    private func setupSubviews() {
        view.addSubview(btnCapture)
        view.addSubview(btnClose)
        
        btnCapture.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: CaptureButtonLength, height: CaptureButtonLength))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-50)
        }
        
        btnClose.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: CaptureButtonLength, height: CaptureButtonLength))
            make.centerX.equalToSuperview().dividedBy(3)
            make.bottom.equalToSuperview().offset(-50)
        }
    }
    
    private func presentCropper(with image: UIImage) {
        let cropVC = CropViewController(image: image)
        cropVC.delegate = self
        present(cropVC, animated: true, completion: nil)
    }
}

extension SessionCameraViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        MainQueue.async {
            cropViewController.dismiss(animated: true) {
                if cancelled {
                    try? self.camera.requestCaptureSessionStart()
                }
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        MainQueue.async {
            cropViewController.dismiss(animated: false, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        delegate?.didCaptureImage(image)
    }
}
extension SessionCameraViewController {
    @objc private func handleClose() {
        try? camera.requestCaptureSessionStop()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleCapture() {
        camera.captureImage { [weak self] (image, error) in
            if error != nil, let error = error as? CameraError {
                var message = "未知错误"
                switch error {
                case .noCaptureSession:
                    message = "noCaptureSession"
                case .noRearCameraAvaliable:
                    message = "noRearCameraAvaliable"
                }
                Bartendar.handleSorryAlert(message: "相机出错：\(message)", on: nil)
                return
            }
            
            guard let self = self, let image = image else {
                debugPrint("oh god! image is nil")
                return
            }
            try? self.camera.requestCaptureSessionStop()
            self.presentCropper(with: image)
        }
    }
}
