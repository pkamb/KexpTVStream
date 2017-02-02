//
//  CurrentlyPlaying.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/30/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

import SwiftyJSON

public struct CurrentlyPlaying {
    let count: Int
    let next: URL?
    let previous: URL?
    let songs: [Song]?
    
    public init(currentlyPlaying: JSON) {
        count = currentlyPlaying["count"].intValue
        next = currentlyPlaying["next"].url
        previous = currentlyPlaying["previous"].url
        
        
        if let resultSongs = currentlyPlaying["results"].array {
            var theSongs = [Song]()
            
            for song in resultSongs {
                 theSongs.append(Song(currentSong: song))
            }
            
            songs = theSongs
        }
        else {
            songs = nil
        }
    }
}
