//
//  SearchResultTableViewCell.swift
//  kvasir
//
//  Created by Monsoir on 6/10/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

class SearchResultTableViewCell: ShadowedTableViewCell {
    static let height = 150 as CGFloat
    
    var attributedTitle: NSAttributedString? {
        set {
            lbTitle.attributedText = newValue
        }
        get {
            return lbTitle.attributedText
        }
    }
    
    var bookName: String? {
        set {
            lbBookName.text = newValue
        }
        get {
            return lbBookName.text
        }
    }
    
    private lazy var lbTitle: TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.font = PingFangSCLightFont?.withSize(22)
        label.numberOfLines = 4
        return label
    }()
    
    private lazy var lbBookName: UILabel = {
        let label = UILabel()
        label.font = PingFangSCLightFont?.withSize(16)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        
        lbTitle.snp.makeConstraints { (make) in
            make.top.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.height.greaterThanOrEqualTo(50)
            make.centerX.equalToSuperview()
        }
        
        lbBookName.snp.makeConstraints { (make) in
            make.top.equalTo(lbTitle.snp.bottom)
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().offset(-8)
            make.height.greaterThanOrEqualTo(30)
        }
        
        realContentView.snp.makeConstraints { (make) in
            make.bottom.equalTo(lbBookName)
        }
        
        super.updateConstraints()
    }
}

private extension SearchResultTableViewCell {
    func setupSubviews() {
        selectionStyle = .none
        realContentView.addSubviews([
            lbTitle,
            lbBookName,
        ])
    }
}
