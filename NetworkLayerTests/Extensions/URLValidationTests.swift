//
//  URLValidationTests.swift
//  NetworkLayerTests
//
//  Created by Akshit Zaveri on 25/02/20.
//  Copyright © 2020 Akshit Zaveri. All rights reserved.
//

import XCTest
@testable import NetworkLayer

class URLValidationTests: XCTestCase {

    var sut: URL!
    
    override func tearDown() {
        sut = nil
    }

    func test_ValidURL_IsValidSuccess() {
        // given
        self.sut = URL(string: "https://google.com")!
        
        // when
        let isValid = self.sut.isValid()
        
        // then
        XCTAssertTrue(isValid)
    }
    
    func test_ValidURL_IsValidError() {
        // given
        self.sut = URL(string: "https-google.com1")!
        
        // when
        let isValid = self.sut.isValid()
        
        // then
        XCTAssertFalse(isValid)
    }

}
