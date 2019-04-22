//
//  DetailInfoTableViewCell.swift
//  kvasir
//
//  Created by Monsoir on 4/21/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class DetailInfoTableViewCell: UITableViewCell {
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
    
    private lazy var lbLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Light", size: 14)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var lbValue: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "PingFangSC-Regular", size: 22)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        
        let margin = 10
        lbLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(margin)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.height.greaterThanOrEqualTo(22).priorityLow()
        }
        
        lbValue.snp.makeConstraints { (make) in
            make.top.equalTo(lbLabel.snp.bottom)
            make.leading.equalTo(lbLabel).offset(5)
            make.trailing.equalTo(lbLabel).offset(-5)
            make.height.greaterThanOrEqualTo(32)
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
            make.bottom.equalTo(lbValue).offset(10)
        }
        
        super.updateConstraints()
    }
    
    private func setupSubviews() {
        contentView.addSubview(lbLabel)
        contentView.addSubview(lbValue)
    }
}
