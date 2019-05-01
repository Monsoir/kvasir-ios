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
    
    var modifying = false {
        didSet {
            if modifying {
                contentView.addSubview(btnEdit)
            } else {
                btnEdit.removeFromSuperview()
            }
            setNeedsUpdateConstraints()
            setNeedsLayout()
        }
    }
    
    var modifyHandler: ((_ cell: DigestDetailTableViewCell) -> Void)?
    
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
    
    private lazy var btnEdit: UIButton = {
        let btn = simpleButtonWithButtonFromAwesomefont(name: .paintBrush)
        btn.addTarget(self, action: #selector(actionModify), for: .touchUpInside)
        return btn
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
        modifying ? updateConstraintsModifying() : updateConstraintsNotModifying()
        
        lbValue.snp.remakeConstraints { (make) in
            make.top.equalTo(lbLabel.snp.bottom)
            make.leading.equalTo(lbLabel).offset(5)
            make.trailing.equalTo(lbLabel).offset(-5)
            make.height.greaterThanOrEqualTo(32)
        }
        
        contentView.snp.remakeConstraints { (make) in
            make.edges.equalTo(self)
            make.bottom.equalTo(lbValue).offset(10)
        }
        super.updateConstraints()
    }
    
    private func updateConstraintsNotModifying() {
        let margin = 10
        lbLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(margin)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalToSuperview().offset(-margin)
            make.height.greaterThanOrEqualTo(22).priorityLow()
        }
    }
    
    private func updateConstraintsModifying() {
        let margin = 10
        lbLabel.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(margin)
            make.leading.equalToSuperview().offset(margin)
            make.trailing.equalTo(btnEdit.snp.leading).offset(-margin)
            make.height.greaterThanOrEqualTo(22).priorityLow()
        }
        
        btnEdit.snp.remakeConstraints { (make) in
            make.size.equalTo(CGSize(width: 22, height: 22))
            make.trailing.equalToSuperview().offset(-margin * 2)
            make.top.equalTo(lbLabel)
        }
    }
    
    private func setupSubviews() {
        contentView.addSubview(lbLabel)
        contentView.addSubview(lbValue)
    }
    
    @objc func actionModify() {
        guard modifying, let handler = modifyHandler else { return }
        handler(self)
    }
}
