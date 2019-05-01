//
//  DetailTableHeaderView.swift
//  kvasir
//
//  Created by Monsoir on 4/20/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

class DigestDetailTableHeaderView: UITableViewHeaderFooterView, Reusable {
    var title: String = "" {
        didSet {
            lbTitle.attributedText = NSAttributedString(string: title, attributes: titleAttributes)
        }
    }
    
    private lazy var lbTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var titleAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-light", size: 20)!
    ]
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        lbTitle.snp.makeConstraints { (make) in
            make.centerY.equalTo(contentView.safeAreaLayoutGuide)
            make.left.equalTo(contentView.safeAreaLayoutGuide.snp.left).offset(8)
        }
        
        super.updateConstraints()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let shadowPath = UIBezierPath(rect: bounds)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.5)
        layer.shadowOpacity = 0.5
        layer.shadowPath = shadowPath.cgPath
    }
}

private extension DigestDetailTableHeaderView {
    func setupSubviews() {
        contentView.addSubview(lbTitle)
    }
}

