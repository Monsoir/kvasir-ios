//
//  DetailInfoTableViewCell.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class DigestDetailTableViewCell: UITableViewCell {
    var label: String? {
        didSet {
            lbLabel.text = label
        }
    }
    
    var value: String? {
        didSet {
            lbValue.text = value
        }
    }
    
    var maxLine: Int {
        set {
            lbValue.numberOfLines = newValue
        }
        get {
            return lbValue.numberOfLines
        }
    }
    
    private lazy var lbLabel: UILabel = {
        let label = UILabel()
        label.font = PingFangSCLightFont?.withSize(14)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var lbValue: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = PingFangSCRegularFont?.withSize(22)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        lbValue.numberOfLines = 1
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        let margin = 10
        lbLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(margin)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.height.greaterThanOrEqualTo(22).priorityLow()
        }
        
        lbValue.snp.remakeConstraints { (make) in
            make.top.equalTo(lbLabel.snp.bottom)
            make.leading.equalTo(lbLabel).offset(5)
            make.trailing.equalTo(lbLabel).offset(-5)
            make.height.greaterThanOrEqualTo(32)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        super.updateConstraints()
    }
    
    private func setupSubviews() {
        contentView.addSubview(lbLabel)
        contentView.addSubview(lbValue)
    }
}
