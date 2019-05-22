//
//  StringExTests.swift
//  kvasirTests
//
//  Created by Monsoir on 5/22/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import XCTest
@testable import kvasir

class StringExTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testMD5Base64() {
        let input = "isbn=9787544380928-2019-05-22T10:39:30.220Z-abc"
        let result = input.msr.md5Base64
        
        // result has been tested by nodejs and ruby
        print(result)
        XCTAssert(result == "G+I89NNisvDpDBV7nVDJcg==", "md5 base64 string is not correct")
    }

}
