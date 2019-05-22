//
//  DateEx.swift
//  kvasir
//
//  Created by Monsoir on 5/22/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

private protocol _DateType {}
extension Date: _DateType {}

// Date now is accessible to msr
// msr is `MsrWrapper` type
extension Date: MsrCompatible {}

// We are not going to extend other functions directly on Date
// Instead, functions will be extended on a property of date, called msr, which can form a kind of namespace
// Since msr is `MsrWrapper` type, so mount the functions on MsrWrapper extension
// And since Date is a struct, which is not generic, and which, is not allowed to be a constraint of `Base`
// Since protocol means generic, we declare a protocol called `_DateType`(which means this protocol is for Date only)
// Then, let struct `Date` implement `_DateType`, which make `Date` generic in a way
// Finally, `Base` will be constrainted to `Date`
extension MsrWrapper where Base: _DateType {
    func ISO8061FormatString() -> String {
        guard let me = base as? Date else { return "" }
        return type(of: me).iso0861Formatter.string(from: me)
    }
}

private extension Date {
    static let iso0861Formatter = ISO8601DateFormatter()
}
