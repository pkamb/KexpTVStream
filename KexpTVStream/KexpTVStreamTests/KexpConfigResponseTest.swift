//
//  KexpConfigResponseUnitTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest

class KexpConfigResponseTest: XCTestCase {

    lazy var configSettings: KexpConfigSettings = self.getKexpSettings()

    func testConfigResponse() {
        XCTAssertNotNil(configSettings);

        XCTAssert(configSettings.streamUrl == "http://live-aacplus-64.kexp.org/kexp64.aac", "Kexp Stream URL not present")
        XCTAssert(configSettings.backupStreamUrl == "http://live-mp3-128.kexp.org:8000/listen.pls", "Back up Kexp Stream URL not present")
        XCTAssert(configSettings.nowPlayingLogo?.characters.count > 0, "Now playing logo is not present")
        XCTAssert(configSettings.updated > 0, "Updated timestamp is not present")
    }
    
    func getKexpSettings() -> KexpConfigSettings {
        let jsonDictionary = KexpTestUtilities.getJSONFromTestFile("KexpConfigResponse")
        let kexpConfigResponse =  KexpConfigSettings(configSettingDictionary: jsonDictionary)
        
        return kexpConfigResponse
    }
}
