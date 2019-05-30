//
//  TopListCollectionViewCellWithoutThumbnail.swift
//  kvasir
//
//  Created by Monsoir on 5/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

class TopListCollectionViewCellWithoutThumbnail: TopListCollectionViewCell {
    override func updateConstraints() {
        lbTitle.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(10)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.bottom.equalTo(lbBookName.snp.top).offset(-8)
        }
        
        lbRecordUpdatedDate.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalTo(lbTitle)
            make.trailing.equalTo(lbTitle)
            make.height.equalTo(22)
        }
        
        lbBookName.snp.makeConstraints { (make) in
            make.bottom.equalTo(lbRecordUpdatedDate.snp.top).offset(-8)
            make.leading.equalTo(lbTitle)
            make.trailing.equalTo(lbTitle)
            make.height.equalTo(25)
        }
        
        gradientTagView.snp.makeConstraints { (make) in
            make.height.equalTo(type(of: self).gradientHeight)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        super.updateConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        layer.cornerRadius = type(of: self).cornerRadius
        contentView.addSubviews([
            lbTitle,
            lbBookName,
            lbRecordUpdatedDate,
            gradientTagView,
        ])
    }
}
