//
//  UICollectionViewEx.swift
//  kvasir
//
//  Created by Monsoir on 5/27/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension UICollectionView: MsrCompatible {}
extension MsrWrapper where Base: UICollectionView {
    func updateRows(deletions: [IndexPath], insertions: [IndexPath], modifications: [IndexPath]) {
        base.deleteItems(at: deletions)
        base.insertItems(at: insertions)
        base.reloadItems(at: modifications)
    }
}
