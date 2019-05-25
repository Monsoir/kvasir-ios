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

class ShadowedView: UIView {
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 阴影 n 要素
        // 水平位移，垂直位移，模糊半径
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false // disable clipping
//        layer.shadowColor = Color(hexString: "#CED1D1")?.cgColor
        layer.shadowColor = UIColor.white.cgColor
        
        // https://stackoverflow.com/a/21383760/5211544
        // how does shadow offset work
        layer.shadowOffset = CGSize(width: 0, height: 0)
        
        layer.shadowOpacity = 0.7
        layer.shadowRadius = 5
        layer.shadowPath = shadowPath.cgPath
    }
}
