//
//  CustomEurekaModel.swift
//  kvasir
//
//  Created by Monsoir on 5/14/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct EurekaLabelValueModel: Equatable {
    var label = ""
    var value = ""
    var info: [String: Any]?
    
    static func == (lhs: EurekaLabelValueModel, rhs: EurekaLabelValueModel) -> Bool {
        return lhs.value == rhs.value
    }
}
