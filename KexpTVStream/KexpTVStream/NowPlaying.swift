//
//  NowPlaying.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/23/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import SwiftyJSON

class NowPlaying {
    var playId: String?
    var album: String?
    var albumArtWork: String?
    var artist: String?
    var songTitle: String?
    var timePlayed = NSDate()
    var airBreak = true
    
    init(nowPlayingJSON: JSON?) {
        guard let nowPlayingJSON = nowPlayingJSON else { return }
        
        playId = nowPlayingJSON["PlayID"].string
        album = nowPlayingJSON["Album"].string
        albumArtWork = nowPlayingJSON["AlbumArt"].string
        artist = nowPlayingJSON["Artist"].string
        songTitle = nowPlayingJSON["SongTitle"].string

        if let breakTime = nowPlayingJSON["AirBreak"].bool {
            airBreak = breakTime
        }
    }
}
