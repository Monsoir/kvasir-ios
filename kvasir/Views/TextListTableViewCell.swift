//
//  TextListTableViewCell.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

class TextListTableViewCell: UITableViewCell {
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
    
    private lazy var lbTitle: TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.font = UIFont(name: "PingFangSC-Regular", size: 25)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var lbBookName: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Light", size: 18)
        return label
    }()
    
    private lazy var lbRecordUpdatedDate: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "PingFangSC-Light", size: 12)
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
        contentView.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(10)
        }

        lbTitle.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(10)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.bottom.equalTo(lbBookName.snp.top).offset(-8)
        }
        
        lbBookName.snp.makeConstraints { (make) in
            make.bottom.equalTo(lbRecordUpdatedDate.snp.top).offset(-8)
            make.leading.equalTo(lbTitle)
            make.trailing.equalTo(lbTitle)
            make.height.lessThanOrEqualTo(25)
        }
        
        lbRecordUpdatedDate.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalTo(lbTitle)
            make.trailing.equalTo(lbTitle)
            make.height.lessThanOrEqualTo(20)
        }
        super.updateConstraints()
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let transform = highlighted ? CGAffineTransform(scaleX: TopListConstants.collectionViewCellScale, y: TopListConstants.collectionViewCellScale) : CGAffineTransform.identity
        UIView.animate(withDuration: TopListConstants.collectionViewCellAnimationDuration) {
            self.transform = transform
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = Color(hexString: ThemeConst.mainBackgroundColor)?.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowOpacity = 0.2
        layer.shadowPath = shadowPath.cgPath
    }
}

private extension TextListTableViewCell {
    func setupSubviews() {
        backgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        selectionStyle = .none
        contentView.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        contentView.layer.cornerRadius = 10
        contentView.addSubview(lbTitle)
        contentView.addSubview(lbBookName)
        contentView.addSubview(lbRecordUpdatedDate)
    }
}
