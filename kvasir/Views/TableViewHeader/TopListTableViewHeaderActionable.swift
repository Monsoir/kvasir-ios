//
//  TopListTableViewHeader.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit
import SwifterSwift

class TopListTableViewHeaderActionable: UITableViewHeaderFooterView, Reusable {
    var title: String = "" {
        didSet {
            lbTitle.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
        }
    }
    
    var seeAllHandler: (() -> Void)? = nil
    var createHandler: (() -> Void)? = nil
    
    private lazy var lbTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var titleAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Medium", size: 28)!
    ]
    
    private lazy var btnSeeAll: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("查看全部", for: .normal)
        view.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.setTitleColor(Color(hexString: ThemeConst.outlineColor), for: .normal)
        view.layer.cornerRadius = 10
        let leadingInset = 15.0 as CGFloat
        let topInset = 20 as CGFloat
        view.contentEdgeInsets = UIEdgeInsets.init(horizontal: leadingInset, vertical: topInset)
        return view
    }()
    
    private lazy var btnCreate: UIButton = {
        let view = UIButton(type: .system)
        view.setTitle("记一个", for: .normal)
        view.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: NSLayoutConstraint.Axis.horizontal)
        view.backgroundColor = Color(hexString: ThemeConst.secondaryBackgroundColor)
        view.setTitleColor(Color(hexString: ThemeConst.outlineColor), for: .normal)
        view.layer.cornerRadius = 10
        let leadingInset = 15.0 as CGFloat
        let topInset = 20 as CGFloat
        view.contentEdgeInsets = UIEdgeInsets.init(horizontal: leadingInset, vertical: topInset)
        return view
    }()
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        lbTitle.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.leading.equalTo(contentView.safeAreaLayoutGuide.snp.leading).offset(8)
        }
        
        btnSeeAll.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide.snp.trailing).offset(-8)
        }
        
//        btnCreate.snp.makeConstraints { (make) in
//            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
//            make.right.equalTo(btnSeeAll.safeAreaLayoutGuide.snp.left).offset(-8)
//        }
        
        super.updateConstraints()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TopListTableViewHeaderActionable {
    func setupSubviews() {
        bindAction()
        contentView.addSubview(lbTitle)
        contentView.addSubview(btnSeeAll)
//        contentView.addSubview(btnCreate)
    }
    
    func bindAction() {
        btnSeeAll.addTarget(self, action: #selector(actionSeeAll), for: .touchUpInside)
//        btnCreate.addTarget(self, action: #selector(actionCreate), for: .touchUpInside)
    }
    
    @objc func actionSeeAll() {
        seeAllHandler?()
    }
    
    @objc func actionCreate() {
        createHandler?()
    }
}
