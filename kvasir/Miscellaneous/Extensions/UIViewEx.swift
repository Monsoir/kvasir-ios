//
//  UIViewEx.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension ViewScalable where Self: UIView {
    func shrinkSize() {
        let scaleTransform = CGAffineTransform(scaleX: TopListConstants.collectionViewCellScale, y: TopListConstants.collectionViewCellScale)
        UIView.animate(withDuration: TopListConstants.collectionViewCellAnimationDuration) {
            self.transform = scaleTransform
        }
    }
    
    func restoreSize() {
        UIView.animate(withDuration: TopListConstants.collectionViewCellAnimationDuration) {
            self.transform = CGAffineTransform.identity
        }
    }
}
