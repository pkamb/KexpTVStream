//
//  NowPlaying.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/23/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit

class NowPlaying: NSObject {
    var album: String?
    var albumArtWork: String?
    var artist: String?
    var songTitle: String?
    var airBreak = true
    
    init(nowPlayingDictionary: NSDictionary) {
        album = nowPlayingDictionary["Album"] as? String
        albumArtWork = nowPlayingDictionary["AlbumArt"] as? String
        artist = nowPlayingDictionary["Artist"] as? String
        songTitle = nowPlayingDictionary["SongTitle"] as? String
        
        if let breakTime = nowPlayingDictionary["AirBreak"] as? Bool {
            airBreak = breakTime
        }
    }
}
