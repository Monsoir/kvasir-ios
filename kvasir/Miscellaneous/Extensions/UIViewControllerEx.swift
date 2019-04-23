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
        let backItem = makeBackButtonWithChevron()
        if let navigationController = self.navigationController {
            if navigationController.viewControllers.count <= 1 {
                backItem.addTargetForAction(self, action: #selector(actionDismiss))
            } else {
                backItem.addTargetForAction(self, action: #selector(actionPop))
            }
        } else {
            backItem.addTargetForAction(self, action: #selector(actionDismiss))
        }
        
        return backItem
    }
    
    @objc private func actionPop() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func actionDismiss() {
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
    
    func setupImmersiveAppearance() {
        removeNavigationBarUnderline()
        removeBackButtonTitle()
    }
}

