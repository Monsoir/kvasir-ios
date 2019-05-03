//
//  SelectableLabel.swift
//  kvasir
//
//  Created by Monsoir on 5/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//
//  https://nshipster.com/uimenucontroller/
//  https://stackoverflow.com/a/39988603/5211544

import UIKit

class SelectableLabel: UILabel {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
}
