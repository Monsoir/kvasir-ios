//
//  ShadowedView.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class ShadowedView: UIView {
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 阴影 n 要素
        // 水平位移，垂直位移，模糊半径
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false // disable clipping
        //        layer.shadowColor = Color(hexString: "#CED1D1")?.cgColor
        layer.shadowColor = UIColor.white.cgColor
        
        // https://stackoverflow.com/a/21383760/5211544
        // how does shadow offset work
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 5
        layer.shadowPath = shadowPath.cgPath
    }
}
