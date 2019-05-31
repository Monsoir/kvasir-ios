//
//  ShortTextFieldEditViewController.swift
//  kvasir
//
//  Created by Monsoir on 5/31/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import Eureka

class ShortTextFieldEditViewController: AbstractFieldEditViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let startEditingAsShown = editInfo?[FieldEditInfoPreDefineKeys.startEditingAsShown] as? Bool, startEditingAsShown {
            let row = form.rowBy(tag: "newValue") as! TextRow
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
            <<< TextRow() { [weak self] in
                $0.tag = "newValue"
                $0.value = editInfo?[FieldEditInfoPreDefineKeys.oldValue] as? String
                $0.title = "\(editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "缺少 title")"
                $0.add(rule: RuleRequired(msg: "\(self?.editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "")不能为空", id: nil))
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
        guard let newValue = values["newValue"] as? String else {
            Bartendar.handleTipAlert(message: "请填写正确页码\(self.editInfo?[FieldEditInfoPreDefineKeys.title] as? String ?? "")", on: nil)
            return
        }
        guard let completion = editInfo?[FieldEditInfoPreDefineKeys.completion] as? FieldEditCompletion else {
            Bartendar.handleSorryAlert(on: self.navigationController ?? self)
            return
        }
        completion(newValue, self)
    }
}
