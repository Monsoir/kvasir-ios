//
//  TopListCollectionViewCell.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class TopListCollectionViewCell: UICollectionViewCell, ViewScalable {
    
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
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowPath = shadowPath.cgPath
    }
}
