//
//  CreateAuthorViewController.swift
//  kvasir
//
//  Created by Monsoir on 4/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Eureka
import SwifterSwift

class CreateCreatorViewController: FormViewController, Configurable {
    
    private let configuration: Configurable.Configuration
    private var creating: Bool {
        return configuration["creating"] as? Bool ?? true
    }
    private var coordinator: CreateCreatorCoordinator
    private var createCompletion: ((_: UIViewController) -> Void)? {
        return configuration["completion"] as? (_: UIViewController) -> Void
    }
    
    private lazy var btnCreateSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionCreateSave))
    
    required init(configuration: Configurable.Configuration) {
        self.configuration = configuration
        self.coordinator = CreateCreatorCoordinator(configuration: configuration)
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
        setupNavigationBar()
        setupSubviews()
    }
    
    @objc private func actionCreateSave() {
        view.endEditing(true)
        
        do {
            try coordinator.post(info: form.values())
        } catch let e as ValidateError {
            Bartendar.handleTipAlert(message: e.message, on: self.navigationController)
            return
        } catch {
            Bartendar.handleSorryAlert(on: self.navigationController)
            return
        }
        
        coordinator.create { [weak self] (success, message) in
            guard let self = self else { return }
            guard success else {
                Bartendar.handleSorryAlert(message: "保存失败", on: self.navigationController)
                return
            }
            
            DispatchQueue.main.async {
                self.createCompletion?(self)
            }
        }
    }
}

private extension CreateCreatorViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = btnCreateSave
        title = "收集一个\(coordinator.entity.category.toHuman)"
    }
    
    func setupSubviews() {
        let character = coordinator.entity.category.toHuman
        
        form +++ Section()
            <<< TextRow() {
                $0.tag = "name"
                $0.value = ""
                $0.title = "\(character)名称"
        }
            <<< TextRow() {
                $0.tag = "localeName"
                $0.value = ""
                $0.title = "\(character)翻译名称"
        }
    }
}
