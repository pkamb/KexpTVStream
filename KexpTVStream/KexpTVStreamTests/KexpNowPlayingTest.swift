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
    lazy var currentlyPlaying: CurrentlyPlaying = self.getNowPlayingResponse()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testCurrentlyPlayingResponse() {
        XCTAssertNotNil(currentlyPlaying)
        
        XCTAssertTrue(currentlyPlaying.count == 2243242)
        XCTAssertTrue(currentlyPlaying.next?.absoluteString == "http://legacy-api.kexp.org/play/?limit=20&offset=20")
        XCTAssertTrue(currentlyPlaying.songs?.count == 20)
    }
    
    func testSongInPayload() {
        let song = currentlyPlaying.songs?[4]
        XCTAssertNotNil(song)
        
        XCTAssertTrue(song?.playId == 2308325)
        XCTAssertTrue(song?.playTypeId == 1)
        XCTAssertTrue(song?.playTypeName == "Media play")
        XCTAssertTrue(song?.airdate == "2017-02-02T04:26:56Z")
        XCTAssertTrue(song?.artistId == 8206)
        XCTAssertTrue(song?.artistName == "Jackie DeShannon")
        XCTAssertTrue(song?.isLocal == false)
        XCTAssertTrue(song?.releaseId == 241372)
        XCTAssertTrue(song?.releaseName == "Laurel Canyon")
        XCTAssertTrue(song?.largeImageUrl?.absoluteString == "http://ecx.images-amazon.com/images/I/51nD-OokW1L.jpg")
        XCTAssertTrue(song?.smallImageUrl?.absoluteString == "http://ecx.images-amazon.com/images/I/51nD-OokW1L._SL75_.jpg")
        XCTAssertTrue(song?.releaseEventId == 303605)
        XCTAssertTrue(song?.releaseEventYear == 1968)
        XCTAssertTrue(song?.trackId == 1050495)
        XCTAssertTrue(song?.trackName == "Laurel Canyon")
        XCTAssertTrue(song?.labelId == 4226)
        XCTAssertTrue(song?.labelName == "Imperial")
    }
    
    func testCommentsInSongFromPayload() {
        let song = currentlyPlaying.songs?.last
        XCTAssertNotNil(song)
        
        XCTAssertTrue(song?.comments?.count == 1)
        
        let comment = song?.comments?.first
        XCTAssertNotNil(comment)
        
        XCTAssertTrue(comment?.commentid == 949045)
        XCTAssertTrue((comment?.commentText?.characters.count)! > 0)
    }
    
    
    func testAirBreakInPayload() {
        let airBreak = currentlyPlaying.songs?[17]
        XCTAssertNotNil(airBreak)
        
        XCTAssertTrue(airBreak?.playTypeId == 4)
        XCTAssertTrue(airBreak?.playTypeName == "Air break")
    }
    
    func getNowPlayingResponse() -> CurrentlyPlaying {
        let JSONData = KexpTestUtilities.getJSONFromTestFile("KexpCurrentlyPlayingResponse")
        
        if let JSONData = JSONData {
            let currentlyPlayingResponse = CurrentlyPlaying(currentlyPlaying: JSONData)
        
            return currentlyPlayingResponse
        }
        
        return CurrentlyPlaying(currentlyPlaying: nil)
    }
}
