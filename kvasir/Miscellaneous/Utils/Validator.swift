//
//  Validator.swift
//  kvasir
//
//  Created by Monsoir on 4/29/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

typealias SimpleValidator = ((_ testee: Any) throws -> Void)

func createNotEmptyStringValidator(_ subject: String) -> SimpleValidator {
    return { (_ testee: Any) in
        if let source = testee as? String, !source.isEmpty { return }
        throw ValidateError(message: "\(subject)不能为空")
    }
}
