//
//  GradientLabel.swift
//  kvasir
//
//  Created by Monsoir on 5/30/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

class GradientView: UIView {
    var gradientColors: [String] = []
    var roundCornerInfo: (corners: UIRectCorner, radius: CGFloat) {
        set {
            roundedCorners = newValue.corners
            radius = newValue.radius
        }
        get {
            return (roundedCorners, radius)
        }
    }
    
    private lazy var tagGradientLayer = CAGradientLayer()
    private var roundedCorners: UIRectCorner = []
    private var radius: CGFloat = 0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setRoundedCorners()
        setTagGradientLayer()
    }
    
    private func setRoundedCorners() {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: roundedCorners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    private func setTagGradientLayer() {
        tagGradientLayer.frame = bounds
        
        if gradientColors.count <= 1 {
            // when gradient color count is less than 1
            // clear the gradient colors, and fallback to background color
            // gradient color layer seems not work with colors less than one
            tagGradientLayer.colors = []
            tagGradientLayer.backgroundColor = {
                guard let hexColor = gradientColors.first else { return UIColor.clear.cgColor }
                return (Color(hexString: hexColor) ?? UIColor.clear).cgColor
            }()
        } else {
            tagGradientLayer.colors = gradientColors.map { Color(hexString: $0)?.cgColor ?? UIColor.clear.cgColor }
        }
        
        // how do start point and end point work
        // https://appcodelabs.com/ios-gradients-how-use-cagradientlayer-swift
        tagGradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        tagGradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        layer.insertSublayer(tagGradientLayer, at: 0)
    }
}
