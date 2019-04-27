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

private typealias InitialValues = (
    name: String,
    localeName: String
)

class CreateCreatorViewController<Creator: RealmCreator>: FormViewController {
    
    private var creating = true
    
    private var initialValues: InitialValues {
        get {
            return (creator.name, creator.localeName)
        }
    }
    private var creator: Creator
    
    private lazy var btnEditSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionEditSave))
    private lazy var btnCreateSave = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionCreateSave))
    
    init(model: Creator, creating: Bool = true) {
        self.creator = model
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
    
    @objc private func actionEditSave() {
        guard putFormValuesToModel() else { return }
    }
    
    @objc private func actionCreateSave() {
        guard putFormValuesToModel() else { return }
        
        guard creator.save() else {
            #warning("错误处理")
            return
        }
        dismiss(animated: true, completion: nil)
    }
}

private extension CreateCreatorViewController {
    func setupNavigationBar() {
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
        navigationItem.rightBarButtonItem = creating ? btnCreateSave : btnEditSave
        title = "收集一个\(Creator.toHuman())"
    }
    
    func setupSubviews() {
        let character = Creator.toHuman()
        
        let values = initialValues
        form +++ Section()
            <<< TextRow() {
                $0.tag = "name"
                $0.value = values.name
                $0.title = "\(character)名称"
        }
            <<< TextRow() {
                $0.tag = "localeName"
                $0.value = values.localeName
                $0.title = "\(character)翻译名称"
        }
    }
}

private extension CreateCreatorViewController {
    func putFormValuesToModel() -> Bool {
        view.endEditing(true)
        let values = form.values()
        let name = (values["name"] as? String ?? "").trimmed
        let localeName = (values["localeName"] as? String ?? "").trimmed
        
        guard !name.isEmpty else {
            let alert = UIAlertController(title: "提示", message: "\(Creator.toHuman())名称不能为空", defaultActionButtonTitle: "确定", tintColor: .black)
            navigationController?.present(alert, animated: true, completion: nil)
            return false
        }
        
        creator.name = name
        creator.localeName = localeName
        return true
    }
}

typealias CreateAuthorViewController = CreateCreatorViewController<RealmAuthor>
typealias CreateTranslatorViewController = CreateCreatorViewController<RealmTranslator>
