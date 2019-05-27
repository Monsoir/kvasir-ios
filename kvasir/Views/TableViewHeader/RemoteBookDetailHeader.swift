//
//  RemoteBookDetailHeader.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import Kingfisher
import SnapKit
import SwifterSwift

private let BookThumbnailSize = (width: 66.0, height: 98.0)
private let BookThumbnailZoomFactor = 1.5
private let LeadingMargin = 10
private let TrailingMargin = 10
private let TopMargin = 10
private let BottomMargin = 10


class RemoteBookDetailHeader: UIView {
    static let height = 180.0 as CGFloat
    var payload: [String: Any]? {
        didSet {
            let thumbnail = payload?["thumbnail"] as? String ?? ""
            let title = payload?["title"] as? String ?? ""
            let detail = payload?["detail"] as? String ?? ""
            
            ivThumbnail.kf.setImage(with: URL(string: thumbnail), placeholder: nil, options: kingfisherOptions)
            lbTitle.attributedText = title.msr.attributedString(with: titleAttributes)
            lbDetail.attributedText = detail.msr.attributedString(with: detailAttributes)
        }
    }
    
    /// （使用自动布局）标记是否可以确定 frame 大小
    private var frameConfirmed: Bool = false
    
    private lazy var ivThumbnail: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.backgroundColor = Color.init(hexString: ThemeConst.secondaryBackgroundColor)
        return imageView
    }()
    private lazy var lbTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }()
    private lazy var lbDetail: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
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
        .redirectHandler(MsrKingfisher()),
        .processor(RoundCornerImageProcessor(cornerRadius: 10 as CGFloat, targetSize: CGSize(width: BookThumbnailSize.width * BookThumbnailZoomFactor, height: BookThumbnailSize.height * BookThumbnailZoomFactor), roundingCorners: .all, backgroundColor: nil))
    ]
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frameConfirmed = true
        setNeedsUpdateConstraints()
        updateConstraintsIfNeeded()
    }
    
    override func updateConstraints() {
        if frameConfirmed {
            ivThumbnail.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().offset(LeadingMargin)
                make.top.equalToSuperview().offset(TopMargin)
                make.size.equalTo(CGSize(width: BookThumbnailSize.width * BookThumbnailZoomFactor, height: BookThumbnailSize.height * BookThumbnailZoomFactor))
                make.bottom.lessThanOrEqualToSuperview().offset(-BottomMargin).priorityHigh()
            }
            
            lbTitle.snp.makeConstraints { (make) in
                make.leading.equalTo(ivThumbnail.snp.trailing).offset(LeadingMargin)
                make.trailing.equalToSuperview().offset(-TrailingMargin)
                make.top.equalToSuperview().offset(TopMargin)
                make.height.greaterThanOrEqualTo(30)
                make.height.lessThanOrEqualTo(90)
            }
            
            lbDetail.snp.makeConstraints { (make) in
                make.leading.equalTo(ivThumbnail.snp.trailing).offset(LeadingMargin)
                make.trailing.equalToSuperview().offset(-TrailingMargin)
                make.top.equalTo(lbTitle.snp.bottom).offset(TopMargin)
                make.height.greaterThanOrEqualTo(30)
                make.height.lessThanOrEqualTo(60)
            }
            
            frameConfirmed = false
        }
        
        super.updateConstraints()
    }
    
    private func setupSubviews() {
        backgroundColor = .white
        addSubviews([
            ivThumbnail,
            lbTitle,
            lbDetail,
        ])
    }
}
