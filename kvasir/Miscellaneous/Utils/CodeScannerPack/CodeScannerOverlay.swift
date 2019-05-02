//
//  CodeScannerOverlay.swift
//  kvasir
//
//  Created by Monsoir on 5/2/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

private let BorderWidth = 2
private let CornerWidth = 4
private let CornerLength = 20

class CodeScannerOverlay: UIView {
    private var emptyRect: CGRect?
    static let overlayColor = UIColor(white: 0, alpha: 0.7)
    
    init(frame: CGRect, emptyRect: CGRect?) {
        super.init(frame: frame)
        self.emptyRect = emptyRect
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // https://github.com/RockChanel/SWQRCode_Swift/blob/ebeec5661204f69b106db414a14fb91c92f880bc/SWQRCode_Swift/SWQRCode/View/SWScannerView.swift#L62
        
        // semi-transparent area
        type(of: self).overlayColor.setFill()
        UIRectFill(rect)
        
        guard let empty = emptyRect else { return }
        
        // transparent area
        UIColor.clear.setFill()
        UIRectFill(empty)
        
        // borders
        let borderPath = UIBezierPath(rect: empty)
        borderPath.lineCapStyle = .square
        borderPath.lineWidth = CGFloat(BorderWidth)
        UIColor.white.set()
        borderPath.stroke()
        
        // corners
        for i in 0...3 {
            let tempPath = UIBezierPath()
            tempPath.lineWidth = CGFloat(CornerWidth)
            UIColor.white.set()
            
            switch i {
            case 0: // top left
                // left <- right ‾
                // top -> bottom |
                tempPath.move(to: CGPoint(x: empty.minX + CGFloat(CornerLength), y: empty.minY))
                tempPath.addLine(to: CGPoint(x: empty.minX, y: empty.minY))
                tempPath.addLine(to: CGPoint(x: empty.minX, y: empty.minY + CGFloat(CornerLength)))
            case 1: // top right
                // left -> right ‾
                // top -> bottom |
                tempPath.move(to: CGPoint(x: empty.maxX - CGFloat(CornerLength), y: empty.minY))
                tempPath.addLine(to: CGPoint(x: empty.maxX, y: empty.minY))
                tempPath.addLine(to: CGPoint(x: empty.maxX, y: empty.minY + CGFloat(CornerLength)))
            case 2: // bottom left
                // left <- right _
                // bottom -> top |
                tempPath.move(to: CGPoint(x: empty.minX + CGFloat(CornerLength), y: empty.maxY))
                tempPath.addLine(to: CGPoint(x: empty.minX, y: empty.maxY))
                tempPath.addLine(to: CGPoint(x: empty.minX, y: empty.maxY - CGFloat(CornerLength)))
            case 3: // bottom right
                // left -> right _
                // bottom -> top |
                tempPath.move(to: CGPoint(x: empty.maxX - CGFloat(CornerLength), y: empty.maxY))
                tempPath.addLine(to: CGPoint(x: empty.maxX, y: empty.maxY))
                tempPath.addLine(to: CGPoint(x: empty.maxX, y: empty.maxY - CGFloat(CornerLength)))
            default:
                break
            }
            tempPath.stroke()
        }
    }
}
