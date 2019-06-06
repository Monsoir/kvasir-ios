//
//  UIViewControllerEx.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension UIViewController {
    func autoGenerateBackItem() -> UIBarButtonItem {
        let backItem = makeBackButton()
        var action: Selector
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.count <= 1 {
                action = #selector(_actionDismiss)
            } else {
                action = #selector(_actionPop)
            }
        } else {
            action = #selector(_actionDismiss)
        }
        
        if let btn = backItem.customView as? UIButton {
            btn.addTarget(self, action: action, for: .touchUpInside)
        } else {
            backItem.addTargetForAction(self, action: action)
        }
        
        // https://stackoverflow.com/a/19076323/5211544
        // Avoid that after customizing navigation bar left item, swipe back gesture is disabled.
        navigationController?.interactivePopGestureRecognizer?.delegate = self as? UIGestureRecognizerDelegate
        return backItem
    }
    
    @objc func _actionPop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func _actionDismiss() {
        dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    func removeNavigationBarUnderline() {
        guard let bar = navigationController?.navigationBar else { return }
        bar.shadowImage = UIImage()
    }
    
    func removeBackButtonTitle() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func setupFontBackButton() {
        navigationItem.backBarButtonItem = UIBarButtonItem(customView: simpleButtonWithButtonFromAwesomefont(name: .chevronLeft))
    }
    
    func setupImmersiveAppearance() {
        removeNavigationBarUnderline()
        removeBackButtonTitle()
    }
}
