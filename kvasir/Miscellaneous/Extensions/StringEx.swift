//
//  StringEx.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

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
        guard type(of: self.base) == String.self, let source = base as? String else {
            return false
        }
        return source.range(of: ISBNRegex.isbn10, options: .regularExpression) != nil || source.range(of: ISBNRegex.isbn13, options: .regularExpression) != nil
    }
}
