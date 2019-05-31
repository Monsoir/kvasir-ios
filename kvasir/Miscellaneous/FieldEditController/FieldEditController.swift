//
//  FieldEditController.swift
//  kvasir
//
//  Created by Monsoir on 5/1/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Eureka

enum FieldEditType {
    case digit
    case shortText // 单行文本
    case longText // 多行文本
}

typealias FieldEditInfo = [String: Any?]
typealias FieldEditCompletion = (_ newValue: Any?, _ vc: UIViewController?) -> Void
typealias FieldEditValidator = RuleType
typealias FieldEditValidatorHandler = (_ messages: [String]) -> Void
struct FieldEditInfoPreDefineKeys {
    static let title = "title"
    static let oldValue = "oldValue"
    static let completion = "completion"
    static let validators = "validators"
    static let validateErrorHandler = "validateErrorHandler"
    static let startEditingAsShown = "startEditingAsShown"
}

class FieldEditFactory {
    static func createAFieldEditController(of type: FieldEditType, editInfo: FieldEditInfo?) -> UIViewController {
        switch type {
        case .digit:
            return DigitFieldEditViewController(editInfo: editInfo)
        case .shortText:
            return ShortTextFieldEditViewController(editInfo: editInfo)
        default:
            return UIViewController()
        }
    }
}
