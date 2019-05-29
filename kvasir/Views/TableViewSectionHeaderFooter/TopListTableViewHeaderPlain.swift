//
//  TopListTableViewHeaderPlain.swift
//  kvasir
//
//  Created by Monsoir on 5/3/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

class TopListTableViewHeaderPlain: UITableViewHeaderFooterView, Reusable {
    var titleAttributes: StringAttributes?
    
    var title: String = "" {
        didSet {
            lbTitle.attributedText = NSAttributedString(string: title, attributes: titleAttributes ?? _titleAttributes)
        }
    }
    
    private lazy var lbTitle: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var _titleAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 25)!
    ]
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override func updateConstraints() {
        lbTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
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
    
    func setupSubviews() {
        contentView.addSubview(lbTitle)
    }
}
