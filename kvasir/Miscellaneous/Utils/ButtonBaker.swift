//
//  UIUtils.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/21.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import FontAwesome_swift

private func makeAFunctionalButton(leadingInset a: CGFloat = 30.0, topInset b: CGFloat = 20.0, cornerRadius c: CGFloat = 10) -> UIButton {
    let btn = UIButton(type: .system)
    btn.setTitleColor(Color(hexString: ThemeConst.outlineColor), for: .normal)
    btn.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
    btn.layer.cornerRadius = c
    btn.contentEdgeInsets = UIEdgeInsets(horizontal: a, vertical: b)
    return btn
}

func simpleButtonWithButtonFromAwesomefont(name: FontAwesome, fontSize: CGFloat = 20) -> UIButton {
    let btn = UIButton(type: .system)
    btn.setTitleColor(Color(hexString: ThemeConst.outlineColor), for: .normal)
    btn.titleLabel?.font = UIFont.fontAwesome(ofSize: fontSize, style: .solid)
    btn.setTitle(String.fontAwesomeIcon(name: name), for: .normal)
    return btn
}

func makeAFunctionalButtonWith(title: String, leadingInset a: CGFloat = 30.0, topInset b: CGFloat = 20.0, cornerRadius c: CGFloat = 10) -> UIButton {
    let btn = makeAFunctionalButton(leadingInset: a, topInset: b, cornerRadius: c)
    btn.setTitle(title, for: .normal)
    return btn
}

func makeAFunctionalButtonFromAwesomeFont(name: FontAwesome, leadingInset a: CGFloat = 30.0, topInset b: CGFloat = 20.0, cornerRadius c: CGFloat = 10) -> UIButton {
    let btn = makeAFunctionalButton(leadingInset: a, topInset: b, cornerRadius: c)
    btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
    btn.setTitle(String.fontAwesomeIcon(name: name), for: .normal)
    return btn
}

func makeAFunctionalButtonFromAwesomeFont(code: String, leadingInset a: CGFloat = 30.0, topInset b: CGFloat = 20.0, cornerRadius c: CGFloat = 10) -> UIButton {
    let btn = makeAFunctionalButton(leadingInset: a, topInset: b, cornerRadius: c)
    btn.titleLabel?.font = UIFont.fontAwesome(ofSize: 25, style: .solid)
    btn.setTitle(String.fontAwesomeIcon(code: code), for: .normal)
    return btn
}

func makeBackButtonFromAwesomeFont() -> UIBarButtonItem {
    let presentedController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    let (target, action): (UIViewController?, Selector?) = {
        let isNavigationController = presentedController?.isKind(of: UINavigationController.self) ?? false
        let target = isNavigationController ? presentedController : nil
        let action: Selector = {
            if isNavigationController {
                if (presentedController as! UINavigationController).viewControllers.count <= 1 && ((presentedController?.presentingViewController) != nil) {
                    return #selector(UINavigationController.dismiss(animated:completion:))
                } else {
                    return #selector(UINavigationController.popViewController(animated:))
                }
            } else {
                return #selector(UIViewController.dismiss(animated:completion:))
            }
        }()
        return (target, action)
    }()
    let btn = UIBarButtonItem(title: String.fontAwesomeIcon(name: .angleLeft), style: .plain, target: target, action: action)
    btn.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 25, style: .solid)], for: .normal)
    return btn
}

func makeBackButton() -> UIBarButtonItem {
    let presentedController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    let (target, action): (UIViewController?, Selector?) = {
        let isNavigationController = presentedController?.isKind(of: UINavigationController.self) ?? false
        let target = isNavigationController ? presentedController : nil
        let action: Selector = {
            if isNavigationController {
                if (presentedController as! UINavigationController).viewControllers.count <= 1 && ((presentedController?.presentingViewController) != nil) {
                    return #selector(UINavigationController.dismiss(animated:completion:))
                } else {
                    return #selector(UINavigationController.popViewController(animated:))
                }
            } else {
                return #selector(UIViewController.dismiss(animated:completion:))
            }
        }()
        return (target, action)
    }()

    if let target = target, let action = action {
        if action == #selector(UINavigationController.dismiss(animated:completion:)) {
            let btn = UIBarButtonItem(customView: simpleButtonWithButtonFromAwesomefont(name: .times))
            btn.addTargetForAction(target, action: action)
            return btn
        } else  {
            let btn = UIBarButtonItem(customView: simpleButtonWithButtonFromAwesomefont(name: .chevronLeft))
            btn.addTargetForAction(target, action: action)
            return btn
        }
    }
    
    return UIBarButtonItem(customView: simpleButtonWithButtonFromAwesomefont(name: .chevronLeft))
}
