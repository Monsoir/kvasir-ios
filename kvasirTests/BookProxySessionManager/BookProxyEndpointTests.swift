//
//  BookProxyEndpointTests.swift
//  kvasir
//
//  Created by Monsoir on 5/13/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import XCTest
@testable import kvasir

class BookProxyEndpointTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGetBookByISBNWithParameters() {
        let parameters = [
            "isbn": "isbn",
            "abc": "abc",
        ]
        let result = BookProxyEndpoint.queryByISBN.getPathWithParameters(parameters)
        if result == nil {
            XCTFail("URL for querying book by ISBN with parameters should not be nil")
        }
        let supposedToBe1 = "\(BookProxySensitive.server)/books/query?isbn=isbn&abc=abc"
        let supposedToBe2 = "\(BookProxySensitive.server)/books/query?abc=abc&isbn=isbn"
        XCTAssert(result! == supposedToBe1 || result! == supposedToBe2, "URL for querying book by ISBN with parameters is wrong")
    }
    
    func testGetBookISBNWithoutParameters() {
        let result = BookProxyEndpoint.queryByISBN.getPathWithParameters(nil)
        if result == nil {
            XCTFail("URL for querying book by ISBN should not be nil")
        }
        let supposedToBe1 = "\(BookProxySensitive.server)/books/query"
        XCTAssert(result! == supposedToBe1, "URL for querying book by ISBN without parameters is wrong")
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
