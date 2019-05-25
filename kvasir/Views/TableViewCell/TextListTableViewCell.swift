//
//  TextListTableViewCell.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SwifterSwift

class TextListTableViewCell: ShadowedTableViewCell {
    static let height = 200
    
    var title: String? = nil {
        didSet {
            lbTitle.text = title
        }
    }
    
    var bookName: String? = nil {
        didSet {
            lbBookName.text = bookName
        }
    }
    
    var recordUpdatedDate: String? = nil {
        didSet {
            lbRecordUpdatedDate.text = recordUpdatedDate
        }
    }
    
    private lazy var lbTitle: TopAlignedLabel = {
        let label = TopAlignedLabel()
        label.font = PingFangSCRegularFont?.withSize(25)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var lbBookName: UILabel = {
        let label = UILabel()
        label.font = PingFangSCLightFont?.withSize(18)
        return label
    }()
    
    private lazy var lbRecordUpdatedDate: UILabel = {
        let label = UILabel()
        label.font = PingFangSCLightFont?.withSize(12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        lbTitle.snp.makeConstraints { (make) in
            make.top.equalTo(realContentView.snp.top).offset(8)
            make.leading.equalTo(realContentView.snp.leading).offset(10).priorityHigh()
            make.trailing.equalTo(realContentView.snp.trailing).offset(-10).priorityHigh()
            make.bottom.equalTo(lbBookName.snp.top).offset(-8)
            make.height.equalTo(100)
        }
        
        lbBookName.snp.makeConstraints { (make) in
            make.bottom.equalTo(lbRecordUpdatedDate.snp.top).offset(-8)
            make.leading.equalTo(lbTitle)
            make.trailing.equalTo(lbTitle)
            make.height.equalTo(25)
        }
        
        lbRecordUpdatedDate.snp.makeConstraints { (make) in
            make.leading.equalTo(lbTitle)
            make.trailing.equalTo(lbTitle)
            make.height.equalTo(20)
        }
        super.updateConstraints()
    }
}

private extension TextListTableViewCell {
    func setupSubviews() {
        contentViewBackgroundColor = Color(hexString: ThemeConst.mainBackgroundColor)
        selectionStyle = .none
        
        realContentView.addSubview(lbTitle)
        realContentView.addSubview(lbBookName)
        realContentView.addSubview(lbRecordUpdatedDate)
    }
}
