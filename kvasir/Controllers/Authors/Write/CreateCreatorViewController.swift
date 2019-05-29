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

class CreateCreatorViewController<Creator: RealmCreator>: FormViewController {
    
    private var creating = true
    private var coordinator: CreateCreatorCoordinator<Creator>
    
    private lazy var btnCreateSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionCreateSave))
    
    init(model: Creator, creating: Bool = true) {
        self.coordinator = CreateCreatorCoordinator<Creator>(entity: model)
        self.creating = creating
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
        
        coordinator.create { (success, message) in
            guard success else {
                Bartendar.handleSorryAlert(message: "保存失败", on: self.navigationController)
                return
            }
            
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}

private extension CreateCreatorViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = btnCreateSave
        title = "收集一个\(Creator.toHuman)"
    }
    
    func setupSubviews() {
        let character = Creator.toHuman
        
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

typealias CreateAuthorViewController = CreateCreatorViewController<RealmAuthor>
typealias CreateTranslatorViewController = CreateCreatorViewController<RealmTranslator>
