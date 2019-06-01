//
//  AsServerViewController.swift
//  kvasir
//
//  Created by Monsoir on 6/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import SnapKit

class AsServerViewController: UIViewController, Configurable {
    private(set) var configuration: Configurable.Configuration
    private lazy var lbPrompt: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = PingFangSCLightFont
        return label
    }()
    
    private lazy var webServer = KvasirWebServer()
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupSubviews()
        
        lbPrompt.text = "开启服务器中..."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webServer.startServer { [weak self] (success, url) in
            guard let self = self else { return }
            
            MainQueue.async {
                if success, let url = url {
                    self.lbPrompt.text = "请在浏览器上访问：\n\(url.absoluteString)"
                } else {
                    self.lbPrompt.text = "开启服务器失败，请稍后再试"
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webServer.stopServer()
    }
    
    private func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        title = "As Server"
    }
    
    private func setupSubviews() {
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        
        view.addSubviews([
            lbPrompt,
        ])
        
        lbPrompt.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().multipliedBy(0.75)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
        }
    }
}
