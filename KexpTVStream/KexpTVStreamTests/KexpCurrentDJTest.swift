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
        
        if let djFirstName = currentDj.djFirstName {
              XCTAssert(djFirstName.characters.count > 0, "No DJ first name found")
        }
        else {
            XCTAssertNotNil(currentDj.djFirstName)
        }
      
        if let djName = currentDj.djName {
            XCTAssert(djName.characters.count > 0, "No DJ name found")
        }
        else {
            XCTAssertNotNil(currentDj.djName)
        }
        
        if let showTitle = currentDj.showTitle {
            XCTAssert(showTitle.characters.count > 0, "No show title found")
        }
        else {
            XCTAssertNotNil(currentDj.showTitle)
        }
        
        if let showType = currentDj.showType {
            XCTAssert(showType.characters.count > 0, "No DJ showType found")
        }
        else {
           XCTAssertNotNil(currentDj.showType)
        }

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
