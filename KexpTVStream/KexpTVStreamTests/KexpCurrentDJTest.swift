//
//  KexpCurrentDJTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest
@testable import KexpTVStream

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
        let JSONData = KexpTestUtilities.getJSONFromTestFile("KexpCurrentDJResponse")
        
        if let JSONData = JSONData {
            let currentDjResponse =  CurrentDj(currentDjJSON: JSONData)
            
            return currentDjResponse
        }
        
        return CurrentDj(currentDjJSON: nil)
    }
}
