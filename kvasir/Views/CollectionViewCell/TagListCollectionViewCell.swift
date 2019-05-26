//
//  TagListCollectionViewCell.swift
//  kvasir
//
//  Created by Monsoir on 5/26/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

class TagListCollectionViewCell: ShadowedCollectionViewCell {
    static let size = CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
    
    var color: UIColor? {
        set {
            circleView.backgroundColor = newValue
        }
        get {
            return circleView.backgroundColor
        }
    }
    
    var title: String? {
        set {
            lbTitle.text = newValue
        }
        get {
            return lbTitle.text
        }
    }
    
    private lazy var circleView: UIView = {
        let view = UIView()
        // one `2` for
        view.layer.cornerRadius = (type(of: self).size.width - type(of: self).inset) / 2 / 2
        return view
    }()
    
    private lazy var lbTitle: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title = ""
        color = nil
    }
    
    override func updateConstraints() {
        circleView.snp.makeConstraints { (make) in
            make.width.height.equalToSuperview().dividedBy(2)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-10)
        }
        
        lbTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(circleView.snp.bottom).offset(5)
        }
        
        super.updateConstraints()
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        realContentView.addSubview(circleView)
        realContentView.addSubview(lbTitle)
    }
}
