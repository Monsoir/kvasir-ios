//
//  ShadowedTableViewCell.swift
//  kvasir
//
//  Created by Monsoir on 5/25/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift
import SnapKit

private let ScaleFactor = 0.9 as CGFloat
private let ScaleDuration = 0.25

class ShadowedTableViewCell: UITableViewCell, ViewScalable {
    
    class var realContentCornerRadius: CGFloat {
        return 0
    }
    
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
        return view
    }()
    
    private lazy var shadowedView: ShadowedView = {
        let view = ShadowedView()
        view.backgroundColor = .clear
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        highlighted ? shrinkSize(scaleX: ScaleFactor, scaleY: ScaleFactor, duration: ScaleDuration) : restoreSize(duration: ScaleDuration)
    }
    
    override func updateConstraints() {
        shadowedView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(horizontal: 30, vertical: 30))
        }
        realContentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        super.updateConstraints()
    }
    
    private func setupSubviews() {
        realContentView.cornerRadius = type(of: self).realContentCornerRadius
        shadowedView.addSubview(realContentView)
        contentView.addSubview(shadowedView)
    }
}

extension ShadowedTableViewCell {
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
}
