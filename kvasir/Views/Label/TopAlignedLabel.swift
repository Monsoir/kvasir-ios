//
//  TopAlignedLabel.swift
//  kvasir-ios
//
//  Created by Monsoir on 2019/3/20.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

/// 向上靠齐的 label
class TopAlignedLabel: UILabel {
    // https://stackoverflow.com/a/28697657/5211544
    override func drawText(in rect: CGRect) {
        if let stringText = text {
            let stringTextAsNSString = stringText as NSString
            let maximunSize = CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude)
            let labelStringSize = stringTextAsNSString.boundingRect(
                with: maximunSize,
                options: NSStringDrawingOptions.usesLineFragmentOrigin,
                attributes: [NSAttributedString.Key.font: font],
                context: nil
                ).size
            super.drawText(in: CGRect(x:0,y: 0,width: self.frame.width, height:ceil(labelStringSize.height)))
        } else {
            super.drawText(in: rect)
        }
    }
}
