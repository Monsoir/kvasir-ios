//
//  ExpandedLabel.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

/// 包含内边距的 UILabel, 此类的左右边距与上下边距分别相同
class ExpandedLabel: UILabel {
    private var myInsets: UIEdgeInsets = .zero
    init(halfHorizontal: CGFloat, halfVertical: CGFloat) {
        super.init(frame: .zero)
        self.myInsets = UIEdgeInsets(horizontal: halfVertical * 2, vertical: halfVertical * 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: myInsets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        // origin rect
        var rect = super.textRect(forBounds: bounds.inset(by: myInsets), limitedToNumberOfLines: numberOfLines)
        
        // final modified rect
        
        // 先还原 text 原本的绘制位置
        rect.origin.x -= myInsets.left
        rect.origin.y -= myInsets.top
        
        // 再直接调整整个 label 的长宽
        rect.size.width += myInsets.horizontal
        rect.size.height += myInsets.vertical
        
        return rect
    }
}
