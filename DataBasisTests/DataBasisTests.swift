//
//  DataBasisTests.swift
//  DataBasisTests
//
//  Created by Jason Jobe on 5/21/16.
//  Copyright © 2016 WildThink. All rights reserved.
//

import XCTest
@testable import DataBasis

class DataBasisTests: XCTestCase {

    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("TestData", ofType: "json")


        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
