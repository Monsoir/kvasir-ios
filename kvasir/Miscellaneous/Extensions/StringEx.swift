//
//  StringEx.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit
import CommonCrypto

// https://forums.swift.org/t/cant-extend-a-generic-type-with-a-non-protocol-constraint/2190/2
protocol _StringType: Hashable {}
extension String: _StringType {}
extension String: MsrCompatible {}

private struct ISBNRegex {
    // https://gist.github.com/oscarmorrison/3744fa216dcfdb3d0bcb
    static let isbn10 = #"^(?:ISBN(?:-10)?:? )?(?=[0-9X]{10}$|(?=(?:[0-9]+[- ]){3})[- 0-9X]{13}$)[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9X]$"#
    static let isbn13 = #"^(?:ISBN(?:-13)?:? )?(?=[0-9]{13}$|(?=(?:[0-9]+[- ]){4})[- 0-9]{17}$)97[89][- ]?[0-9]{1,5}[- ]?[0-9]+[- ]?[0-9]+[- ]?[0-9]$"#
}

extension MsrWrapper where Base: _StringType {
    func attributedString(with attributes: StringAttributes) -> NSAttributedString? {
        guard type(of: self.base) == String.self, let source = base as? String else { return nil}
        return NSAttributedString(string: source, attributes: attributes)
    }
    
    var isISBN: Bool {
        return isISBN10 || isISBN13
    }
    
    var isISBN10: Bool {
        guard type(of: self.base) == String.self, let source = base as? String else {
            return false
        }
        return source.range(of: ISBNRegex.isbn10, options: .regularExpression) != nil
    }
    
    var isISBN13: Bool {
        guard type(of: self.base) == String.self, let source = base as? String else {
            return false
        }
        return source.range(of: ISBNRegex.isbn13, options: .regularExpression) != nil
    }
    
    var md5Base64: String {
        // https://stackoverflow.com/a/53044349/5211544
        // https://stackoverflow.com/a/56256719/5211544
        guard let me = base as? String else { return "" }
        
        let md5edData = Data(bytes: type(of: self).md5(me))
        return md5edData.base64EncodedString()
    }
    
    private static func md5(_ string: String) -> [UInt8] {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        
        if let d = string.data(using: String.Encoding.utf8) {
            _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
                CC_MD5(body, CC_LONG(d.count), &digest)
            }
        }
        return digest
    }
}

extension StringProtocol { // for Swift 4.x syntax you will needed also to constrain the collection Index to String Index - `extension StringProtocol where Index == String.Index`
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

