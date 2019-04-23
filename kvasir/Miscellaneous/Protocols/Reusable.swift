//
//  Reusable.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

protocol Reusable {
    static func reuseIdentifier() -> String
}

extension Reusable {
    static func reuseIdentifier() -> String {
        return String(describing: self)
    }
}

extension UITableViewCell: Reusable {}
