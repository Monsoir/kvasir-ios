//
//  Reusable.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/18.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

protocol Reusable {
    static func reuseIdentifier(extra: String?) -> String
}

extension Reusable {
    static func reuseIdentifier(extra: String? = nil) -> String {
        guard let e = extra else {
            return String(describing: self)
        }
        return "\(String(describing: self)) - \(e)"
    }
}

extension UITableViewCell: Reusable {}
