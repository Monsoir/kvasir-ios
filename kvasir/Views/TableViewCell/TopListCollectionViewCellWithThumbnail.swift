//
//  TopListCollectionViewCellWithThumbnail.swift
//  kvasir
//
//  Created by Monsoir on 5/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import Kingfisher

class TopListCollectionViewCellWithThumbnail: TopListCollectionViewCell {
    static let BookThumbnailSize = (width: 66.0, height: 98.0)
    
    var thumbnail = "" {
        didSet {
            ivThumbnail.kf.setImage(with: URL(string: thumbnail), placeholder: nil, options: kingfisherOptions)
        }
    }
    
    private lazy var kingfisherOptions: KingfisherOptionsInfo = [
        // 对于普通的 Redirect, Kingfisher 可能内置了处理
        // 不过这里就显式声明一下吧
        .redirectHandler(MsrKingfisher()),
        
        // 使用 Kingfiser 的圆角处理
        .processor(RoundCornerImageProcessor(cornerRadius: 10 as CGFloat, targetSize: CGSize(width: BookListTableViewCell.BookThumbnailSize.width * BookListTableViewCell.BookThumbnailZoomFactor, height: BookListTableViewCell.BookThumbnailSize.height * BookListTableViewCell.BookThumbnailZoomFactor), roundingCorners: .all, backgroundColor: nil))
    ]
    
    private(set) lazy var ivThumbnail: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.backgroundColor = UIColor(hexString: ThemeConst.secondaryBackgroundColor)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        ivThumbnail.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(10)
            make.size.equalTo(
                CGSize(
                    width: BookListTableViewCell.BookThumbnailSize.width * BookListTableViewCell.BookThumbnailZoomFactor,
                    height: BookListTableViewCell.BookThumbnailSize.height * BookListTableViewCell.BookThumbnailZoomFactor)
            )
        }
        
        lbTitle.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.safeAreaLayoutGuide.snp.top).offset(8)
            make.leading.equalTo(ivThumbnail.snp.trailing).offset(8)
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
        super.updateConstraints()
    }
    
    func setupSubviews() {
        backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        layer.cornerRadius = 10
        contentView.addSubviews([
            ivThumbnail,
            lbTitle,
            lbBookName,
            lbRecordUpdatedDate,
        ])
    }
}
