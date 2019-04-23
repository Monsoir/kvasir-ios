//
//  NSAttributedStringEx.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension NSAttributedString {
    func height(containerWidth: CGFloat) -> CGFloat {
        let rect = self.boundingRect(with: CGSize.init(width: containerWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return ceil(rect.size.height)
    }
}
