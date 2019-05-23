//
//  UIImageEx.swift
//  kvasir
//
//  Created by Monsoir on 4/23/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

extension UIImage {
    func fixOrientation() -> UIImage? {
        guard imageOrientation != .up else { return self }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        var result: UIImage? = nil
        draw(in: CGRect(origin: .zero, size: size))
        result = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIImage {
    func scaleImage(_ maxDimension: CGFloat) -> UIImage? {
        
        var scaledSize = CGSize(width: maxDimension, height: maxDimension)
        
        if size.width > size.height {
            let scaleFactor = size.height / size.width
            scaledSize.height = scaledSize.width * scaleFactor
        } else {
            let scaleFactor = size.width / size.height
            scaledSize.width = scaledSize.height * scaleFactor
        }
        
        UIGraphicsBeginImageContext(scaledSize)
        draw(in: CGRect(origin: .zero, size: scaledSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

extension UIImage: MsrCompatible {}
extension MsrWrapper where Base: UIImage {
    func scaleImageJPEGDataFitToProperFileSize(limited to: Double) -> Data? {
        guard let imageData = base.jpegData(compressionQuality: 1) else { return nil }
        
        // calculate as byte
        let originJPEGFileSize = Double(imageData.count)
        
        // the max is larger than the origin file size, just return
        if to >= originJPEGFileSize {
            return imageData
        }
        
        // origin file size is larger than the max, scale it
        // compression quality scales from 0.0 to 1.0
        // as a result, limit should be divived by origin
        let factor = to / originJPEGFileSize
        return base.jpegData(compressionQuality: CGFloat(factor))
    }
}
