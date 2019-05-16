//
//  BookListTableViewCell.swift
//  kvasir
//
//  Created by Monsoir on 4/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift
import Kingfisher

private let BookThumbnailSize = (width: 66.0, height: 98.0)
private let BookThumbnailZoomFactor = 1.5
private let LeadingMargin = 10
private let TrailingMargin = 10
private let TopMargin = 10
private let BottomMargin = 10

class BookListTableViewCell: UITableViewCell {
    static let height = UITableView.automaticDimension
    
    private var needThumbnail: Bool
    
    var payload: [String: Any]? {
        didSet {
            let thumbnail = payload?["thumbnail"] as? String ?? ""
            let title = payload?["title"] as? String ?? ""
            let author = payload?["author"] as? String ?? ""
            let publisher = payload?["publisher"] as? String ?? ""
            let sentencesCount = payload?["sentencesCount"] as? Int ?? 0
            let paragraphsCount = payload?["paragraphsCount"] as? Int ?? 0
            
            let detail = [author, publisher].joined(separator: "/")
            let digest = ["\(sentencesCount)个句摘", "\(paragraphsCount)个段摘"].joined(separator: "/")
            
            ivThumbnail.kf.setImage(with: URL(string: thumbnail), placeholder: nil, options: kingfisherOptions)
            lbTitle.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
            lbDetail.attributedText = NSAttributedString(string: detail, attributes: detailAttributes)
            lbDigest.attributedText = NSAttributedString(string: digest, attributes: detailAttributes)
        }
    }
    
    private lazy var ivThumbnail: UIImageView = {
        let imageView = UIImageView()
        // image view 不要使用此方法添加圆角
        // 会遮蔽图片显示
        // 被这行代码搞了2个小时了
//        imageView.roundCorners([.allCorners], radius: 10 as CGFloat)
        imageView.contentMode = .center
        return imageView
    }()
    private lazy var lbTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    private lazy var lbDetail: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    private lazy var lbDigest: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var titleAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .medium),
    ]
    private lazy var detailAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        NSAttributedString.Key.foregroundColor: UIColor.lightGray,
    ]
    private lazy var kingfisherOptions: KingfisherOptionsInfo = [
        // 对于普通的 Redirect, Kingfisher 可能内置了处理
        // 不过这里就显式声明一下吧
        .redirectHandler(MsrKingfisher()),
        
        // 使用 Kingfiser 的圆角处理
        .processor(RoundCornerImageProcessor(cornerRadius: 10 as CGFloat, targetSize: CGSize(width: BookThumbnailSize.width * BookThumbnailZoomFactor, height: BookThumbnailSize.height * BookThumbnailZoomFactor), roundingCorners: .all, backgroundColor: nil))
    ]
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, needThumbnail: Bool = false) {
        self.needThumbnail = needThumbnail
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        payload = nil
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        
        if needThumbnail {
            ivThumbnail.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(LeadingMargin)
                make.top.equalToSuperview().offset(TopMargin)
                make.size.equalTo(CGSize(width: BookThumbnailSize.width * BookThumbnailZoomFactor, height: BookThumbnailSize.height * BookThumbnailZoomFactor))
                make.bottom.lessThanOrEqualToSuperview().offset(-BottomMargin)
            }
        }
        
        lbTitle.snp.makeConstraints { (make) in
            make.leading.equalTo(needThumbnail ? ivThumbnail.snp.trailing : contentView).offset(LeadingMargin)
            make.trailing.equalToSuperview().offset(-TrailingMargin)
            make.top.equalToSuperview().offset(TopMargin)
            make.height.greaterThanOrEqualTo(30)
        }
        
        lbDetail.snp.makeConstraints { (make) in
            make.leading.equalTo(needThumbnail ? ivThumbnail.snp.trailing : contentView).offset(LeadingMargin)
            make.trailing.equalToSuperview().offset(-TrailingMargin)
            make.top.equalTo(lbTitle.snp.bottom).offset(TopMargin)
            make.height.greaterThanOrEqualTo(30)
        }
        
        lbDigest.snp.makeConstraints { (make) in
            make.leading.equalTo(needThumbnail ? ivThumbnail.snp.trailing : contentView).offset(LeadingMargin)
            make.trailing.equalToSuperview().offset(-TrailingMargin)
            make.top.equalTo(lbDetail.snp.bottom).offset(TopMargin)
            make.height.greaterThanOrEqualTo(30)
            make.bottom.lessThanOrEqualToSuperview().offset(-BottomMargin)
        }
        
        super.updateConstraints()
    }
    
    private func setupSubviews() {
        if needThumbnail {
            contentView.addSubview(ivThumbnail)
        }
        contentView.addSubviews([
            lbTitle,
            lbDetail,
            lbDigest,
        ])
    }
}
