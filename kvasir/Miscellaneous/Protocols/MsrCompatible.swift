//
//  MsrCompatible.swift
//  kvasir
//
//  Created by Monsoir on 5/15/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import UIKit

struct MsrWrapper<Base> {
    let base: Base
    init(_ base: Base) {
        self.base = base
    }
}

protocol MsrCompatible {}

extension MsrCompatible {
    var msr: MsrWrapper<Self> {
        get { return MsrWrapper(self) }
        set { }
    }
}
