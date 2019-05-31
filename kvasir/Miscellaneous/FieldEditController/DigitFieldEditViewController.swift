//
//  DigitFieldEditViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Eureka
import SwifterSwift

extension FieldEditInfoPreDefineKeys {
    static let greaterOrEqualThan = "greaterOrEqualThan"
}

class DigitFieldEditViewController: AbstractFieldEditViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let startEditingAsShown = editInfo?[FieldEditInfoPreDefineKeys.startEditingAsShown] as? Bool, startEditingAsShown {
            let row = form.rowBy(tag: "newValue") as! IntRow
            row.cell.textField.becomeFirstResponder()
        }
    }
    
    override func setupNavigationBar() {
        super.setupNavigationBar()
        navigationItem.rightBarButtonItem = btnSaveItem
        title = "编辑\(editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "")"
    }
    
    override func setupSubviews() {
        tableView.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        form +++ Section()
            <<< IntRow() { [weak self] in
                $0.tag = "newValue"
                $0.value = editInfo?[FieldEditInfoPreDefineKeys.oldValue] as? Int
                $0.title = "\(editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "缺少 title")"
                if let min = self?.editInfo?[FieldEditInfoPreDefineKeys.greaterOrEqualThan] as? Int {
                    $0.add(rule: RuleGreaterOrEqualThan(min: 0, msg: "\(self?.editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "")需大于\(min)"))
                }
        }
    }
    
    override func put() {
        let errors = form.validate()
        if errors.count > 0 {
            if let handler = editInfo?[FieldEditInfoPreDefineKeys.validateErrorHandler] as? FieldEditValidatorHandler {
                let messages = errors.map { $0.msg }
                handler(messages)
                return
            }
        }
        
        let values = form.values()
        guard let newValue = values["newValue"] as? Int else {
            Bartendar.handleTipAlert(message: "请填写正确\(self.editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "")", on: nil)
            return
        }
        guard let completion = editInfo?[FieldEditInfoPreDefineKeys.completion] as? FieldEditCompletion else {
            Bartendar.handleSorryAlert(on: self.navigationController ?? self)
            return
        }
        completion(newValue, self)
    }
}
