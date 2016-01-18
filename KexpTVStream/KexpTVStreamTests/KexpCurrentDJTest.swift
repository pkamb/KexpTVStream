//
//  KexpCurrentDJTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest

class KexpCurrentDJTest: XCTestCase {

    lazy var currentDj: CurrentDj = self.getCurrentDJResponse()
    
    func testConfigResponse() {
        XCTAssertNotNil(currentDj);
        
        XCTAssert(currentDj.djFirstName?.characters.count > 0, "No DJ first name found")
        XCTAssert(currentDj.djName?.characters.count > 0, "No DJ name found")
        XCTAssert(currentDj.showTitle?.characters.count > 0, "No show title found")
        XCTAssert(currentDj.showType?.characters.count > 0, "No DJ showType found")
    }
    
    func getCurrentDJResponse() -> CurrentDj {
        let jsonDictionary = KexpTestUtilities.getJSONFromTestFile("KexpCurrentDJResponse")
        let currentDjResponse =  CurrentDj.init(currentDjDictionary: jsonDictionary)
        
        return currentDjResponse
    }
}
