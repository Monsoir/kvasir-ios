//
//  BookProxySessionManagerTests.swift
//  kvasirTests
//
//  Created by Monsoir on 5/13/19.
//  Copyright © 2019 monsoir. All rights reserved.
//

import XCTest
@testable import kvasir

class BookProxySessionManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSingleton() {
        let manager1 = BookProxySessionManager.shared
        let manager2 = BookProxySessionManager.shared

        XCTAssertTrue(manager1 === manager2, "\(BookProxySessionManager.self) is not singleton")
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
