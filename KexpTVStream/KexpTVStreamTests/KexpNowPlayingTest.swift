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
        XCTAssertNotNil(nowPlaying)
        
        if let playId = nowPlaying.playId {
            XCTAssert(playId.characters.count > 0, "No play Id found")
        }
        else {
            XCTAssertNotNil(nowPlaying.playId)
        }
        
        if let album = nowPlaying.album {
            XCTAssert(album.characters.count > 0, "No album Found")
        }
        else {
            XCTAssertNotNil(nowPlaying.album)
        }
        
        if let albumArtWork = nowPlaying.albumArtWork {
            XCTAssert(albumArtWork.characters.count > 0, "No album Artwork found")
        }
        else {
            XCTAssertNotNil(nowPlaying.albumArtWork)
        }
        
        if let artist = nowPlaying.artist {
            XCTAssert(artist.characters.count > 0, "No artist found")
        }
        else {
            XCTAssertNotNil(nowPlaying.artist)
        }
        
        if let songTitle = nowPlaying.songTitle {
            XCTAssert(songTitle.characters.count > 0, "No song title found")
        }
        else {
            XCTAssertNotNil(nowPlaying.songTitle)
        }
        
//        if let airBreak = nowPlaying.airBreak {
//            
//        }
//        else {
//        
//        
        
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
