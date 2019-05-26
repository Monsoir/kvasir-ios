//
//  CodeScannerViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import AVFoundation
import SnapKit

protocol CodeScannerViewControllerDelegate: class {
    func codeScannerViewController(_ vc: CodeScannerViewController, didScanCode code: String) -> Void
}

typealias CodeScanCompletion = (_ code: String, _ controller: CodeScannerViewController) -> Void
class CodeScannerViewController: UIViewController {
    weak var delegate: CodeScannerViewControllerDelegate?
    
    private var scanner: CodeScanner?
    private var interestRect = CGRect.zero
    private var isFlashOn = false
    private var codeType: CodeScanType
    
    init(codeType type: CodeScanType) {
        self.codeType = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        #if DEBUG
        print("\(self) deinit")
        #endif
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSubviews()
        scanner?.requestSetupSession(previewOn: view, notEnoughAuthorizationHandler: {
            Bartendar.handleTipAlert(message: "没有足够权限使用摄像头", on: nil)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        MainQueue.asyncAfter(deadline: DispatchTime.now() + .nanoseconds(1)) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.scanner?.requestCaptureSessionStart(completion: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toggleFlashlight(forceValue: false)
        scanner?.requestCaptureSessionStop(completion: nil)
    }
    
    private func setupSubviews() {
        view.backgroundColor = .black
        
        let width = view.bounds.width * 0.8
        let x = (view.bounds.width - width) / 2
        let y = view.bounds.height * 0.1
        interestRect = CGRect(x: x, y: y, width: width, height: width)
        
        scanner = CodeScanner(codeType: self.codeType, interestRect: interestRect) { [weak self] (success, code) in
            guard success, let self = self else { return }
            self.delegate?.codeScannerViewController(self, didScanCode: code)
        }
        
        let overlay = CodeScannerOverlay(frame: view.bounds, emptyRect: interestRect)
        view.addSubview(overlay)
        
        let btnClose = simpleButtonWithButtonFromAwesomefont(name: .times, fontSize: 30)
        btnClose.addTarget(self, action: #selector(actionClose), for: .touchUpInside)
        
        let btnFlashLight = simpleButtonWithButtonFromAwesomefont(name: .lightbulb, fontSize: 30)
        btnFlashLight.addTarget(self, action: #selector(actionToggleLight), for: .touchUpInside)
        
        let btnLibrary = simpleButtonWithButtonFromAwesomefont(name: .images, fontSize: 30)
        btnLibrary.addTarget(self, action: #selector(actionChooseFromLibrary), for: .touchUpInside)
        
        let length = 40
        let margin = 10
        [(btnClose, 0.3), (btnFlashLight, 1), (btnLibrary, 1.7)].forEach { (btn, factor) in
            view.addSubview(btn)
            btn.setTitleColor(.white, for: .normal)
            btn.snp.makeConstraints { (make) in
                make.size.equalTo(CGSize(width: length, height: length))
                make.centerY.equalTo(interestRect.maxY + CGFloat(length + margin))
                make.centerX.equalToSuperview().multipliedBy(factor)
            }
        }
    }
    
    @objc private func actionClose() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func actionToggleLight() {
        toggleFlashlight()
    }
    
    private func toggleFlashlight(forceValue: Bool? = nil) {
        if let value = forceValue {
            CodeScanner.triggerFlashlight(on: value)
            isFlashOn = value
        } else {
            CodeScanner.triggerFlashlight(on: !isFlashOn)
            isFlashOn.toggle()
        }
    }
    
    func startScanning() {
        scanner?.requestCaptureSessionStart(completion: nil)
    }
    
    func stopScanning() {
        scanner?.requestCaptureSessionStop(completion: nil)
    }
    
    @objc private func actionChooseFromLibrary() {
        
    }
}
