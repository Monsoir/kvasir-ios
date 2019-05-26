//
//  ShadowedCollectionViewCell.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class ShadowedCollectionViewCell: UICollectionViewCell {
    static let inset = 30 as CGFloat
    var contentViewBackgroundColor: UIColor? {
        get {
            return realContentView.backgroundColor
        }
        set {
            realContentView.backgroundColor = newValue
        }
    }
    
    private(set) var realContentView: UIView = {
        let view = UIView()
        view.cornerRadius = 10
        return view
    }()
    
    private lazy var shadowedView: ShadowedView = {
        let view = ShadowedView()
        view.backgroundColor = .clear
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        shadowedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: type(of: self).inset, vertical: type(of: self).inset))
        }
        realContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        contentView.addSubview(shadowedView)
        shadowedView.addSubview(realContentView)
    }
}
