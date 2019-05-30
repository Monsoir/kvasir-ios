//
//  TopListCollectionViewCell.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class TopListCollectionViewCell: UICollectionViewCell, ViewScalable {
    
    static let gradientHeight = 5 as CGFloat
    static let cornerRadius = 10 as CGFloat
    
    var title: String? = nil {
        didSet {
            lbTitle.text = title
        }
    }
    
    var bookName: String? = nil {
        didSet {
            lbBookName.text = bookName
        }
    }
    
    var recordUpdatedDate: String? = nil {
        didSet {
            lbRecordUpdatedDate.text = recordUpdatedDate
        }
    }
    
    var tagColors: [String] {
        get {
            return gradientTagView.gradientColors
        }
        set {
            gradientTagView.gradientColors = newValue
            
            // force to repaint, otherwise, the tag color remains the old ones
            gradientTagView.setNeedsLayout()
            gradientTagView.layoutIfNeeded()
        }
    }
    
    private(set) lazy var lbTitle: TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.font = PingFangSCRegularFont?.withSize(22)
        label.numberOfLines = 0
        return label
    }()
    
    private(set) lazy var lbBookName: UILabel = {
        let label = UILabel()
        label.font = PingFangSCLightFont?.withSize(18)
        return label
    }()
    
    private(set) lazy var lbRecordUpdatedDate: UILabel = {
        let label = UILabel()
        label.font = PingFangSCLightFont?.withSize(12)
        return label
    }()
    
    private(set) lazy var gradientTagView: GradientView = {
        let view = GradientView()
        view.roundCornerInfo = ([UIRectCorner.bottomLeft, UIRectCorner.bottomRight], type(of: self).cornerRadius)
        return view
    }()
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagColors = []
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        enshadow()
    }
    
    private func enshadow() {
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowPath = shadowPath.cgPath
    }
}
