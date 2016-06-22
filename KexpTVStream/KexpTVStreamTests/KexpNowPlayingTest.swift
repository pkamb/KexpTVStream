//
//  KexpNowPlayingTest.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import XCTest
@testable import KexpTVStream

class KexpNowPlayingTest: XCTestCase {
    lazy var nowPlaying: NowPlaying = self.getNowPlayingResponse()
    
    func testConfigResponse() {
        XCTAssertNotNil(nowPlaying);
        
        XCTAssert(nowPlaying.playId?.characters.count > 0, "No play Id found")
        XCTAssert(nowPlaying.album?.characters.count > 0, "No album Found")
        XCTAssert(nowPlaying.albumArtWork?.characters.count > 0, "No album Artwork found")
        XCTAssert(nowPlaying.artist?.characters.count > 0, "No artist found")
        XCTAssert(nowPlaying.songTitle?.characters.count > 0, "No song title found")
        XCTAssert(nowPlaying.airBreak == false, "Issue with airbreak")
    }
    
    func getNowPlayingResponse() -> NowPlaying {
        let JSONData = KexpTestUtilities.getJSONFromTestFile("KexpNowPlayingResponse")
        
        if let JSONData = JSONData {
            let nowPlayingResponse =  NowPlaying(nowPlayingJSON: JSONData)
        
            return nowPlayingResponse
        }
        
        return NowPlaying(nowPlayingJSON: nil)
    }
}
