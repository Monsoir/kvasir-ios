//
//  PlainTextView.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

class PlainTextViewFooter: UITableViewHeaderFooterView, Reusable {
    static let height = 80 as CGFloat
    
    var titleAttributes: StringAttributes?
    var title: String? {
        get {
            return lbTitle.text
        }
        set {
            lbTitle.attributedText = NSAttributedString(string: newValue ?? "", attributes: titleAttributes ?? _titleAttributes)
        }
    }
    private lazy var _titleAttributes: StringAttributes = [
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 18)!
    ]
    private lazy var lbTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.backgroundColor = .white
        return label
    }()
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        contentView.addSubview(lbTitle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        lbTitle.snp.makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(horizontal: 10, vertical: 10))
        }
        super.updateConstraints()
    }
}
