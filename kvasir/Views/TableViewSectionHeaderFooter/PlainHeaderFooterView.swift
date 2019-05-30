//
//  PlainHeaderFooterView.swift
//  kvasir
//
//  Created by Monsoir on 5/30/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import SnapKit

class PlainHeaderFooterView: UITableViewHeaderFooterView {
    var realBackgroundColor: UIColor = .white
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = realBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
