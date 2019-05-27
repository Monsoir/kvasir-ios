//
//  TagDetailHeader.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

class TagDetailHeader: UIView {
    static let height = 100 as CGFloat
    
    var title: String? {
        set {
            lbTitle.attributedText = NSAttributedString(string: newValue ?? "", attributes: titleAttributes)
        }
        get {
            return lbTitle.text
        }
    }
    var color: UIColor? {
        set {
            colorView.backgroundColor = newValue
        }
        get {
            return colorView.backgroundColor
        }
    }
    
    private lazy var lbTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = type(of: self).height / 3 / 2
        return view
    }()
    private lazy var _contentView: ShadowedView = {
        let view = ShadowedView()
        return view
    }()
    private lazy var contentView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var titleAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont(name: "Helvetica-Light", size: 22)!,
    ]
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        _contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 20, vertical: 20))
        }
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        colorView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(CGSize(width: type(of: self).height / 3, height: type(of: self).height / 3))
        }
        
        lbTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(colorView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }

        super.updateConstraints()
    }
    
    private func setupSubviews() {
        backgroundColor = .clear
        addSubview(_contentView)
        _contentView.addSubviews([
            contentView,
            colorView,
            lbTitle,
        ])
    }
}
