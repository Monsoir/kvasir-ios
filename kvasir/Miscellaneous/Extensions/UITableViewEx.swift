//
//  UITableViewEx.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension UITableView: MsrCompatible {}
extension MsrWrapper where Base: UITableView {
    func updateRows(deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath], with animations: UITableView.RowAnimation = .automatic) {
        base.beginUpdates()
        base.deleteRows(at: deletions, with: animations)
        base.insertRows(at: insertions, with: animations)
        base.reloadRows(at: modifications, with: animations)
        base.endUpdates()
    }
}
