//
//  AbstractFieldEditViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Eureka

class AbstractFieldEditViewController: FormViewController {
    private(set) var editInfo: FieldEditInfo?
    
    private(set) lazy var btnSaveItem = UIBarButtonItem(title: "保存", style: .done, target: self, action: #selector(actionSave))
    
    init(editInfo: FieldEditInfo?) {
        self.editInfo = editInfo
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
        
        setupNavigationBar()
        setupSubviews()
    }
    
    func setupNavigationBar() {
        // do nothing here!
        setupImmersiveAppearance()
        navigationItem.leftBarButtonItem = autoGenerateBackItem()
    }
    
    func setupSubviews() {
        #if DEBUG
        print("\(self): override `setupSubviews` method in subclass and no need to call super's")
        #endif
    }
    
    func put() {
        #if DEBUG
        print("\(self): override `put` method in subclass and no need to call super's")
        #endif
    }
    
    @objc func actionSave() {
        view.endEditing(true)
        put()
    }
}
