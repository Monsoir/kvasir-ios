//
//  UIViewAbilities.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

protocol ViewScalable where Self: UIView {
    func shrinkSize(scaleX: CGFloat, scaleY: CGFloat, duration: TimeInterval)
    func restoreSize(duration: TimeInterval)
}

extension ViewScalable {
    func shrinkSize(scaleX: CGFloat, scaleY: CGFloat, duration: TimeInterval) {
        let scaleTransform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        UIView.animate(withDuration: duration) {
            self.transform = scaleTransform
        }
    }
    
    func restoreSize(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform.identity
        }
    }
}
