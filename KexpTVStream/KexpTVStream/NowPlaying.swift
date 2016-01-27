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
    let album: String?
    let albumArtWork: String?
    let artist: String?
    let songTitle: String?
    let airBreak :Bool?
    
    init(nowPlayingJSON: JSON) {
        album = nowPlayingJSON["Album"].string
        albumArtWork = nowPlayingJSON["AlbumArt"].string
        artist = nowPlayingJSON["Artist"].string
        songTitle = nowPlayingJSON["SongTitle"].string
        airBreak = nowPlayingJSON["AirBreak"].bool
    }
}
