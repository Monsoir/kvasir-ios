//
//  DigestSearchResult.swift
//  kvasir
//
//  Created by Monsoir on 6/10/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import Foundation

struct DigestSearchResult {
    var id: String
    var content: String
    var bookName: String
    var ranges: [Range<String.Index>]
}
