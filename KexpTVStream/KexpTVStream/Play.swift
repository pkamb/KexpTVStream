//
//  CurrentlyPlaying.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/30/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

//import SwiftyJSON
//
//public struct Play {
//    let count: Int
//    let next: URL?
//    let previous: URL?
//    let songs: [Song]?
//    
//    public init(_ play: JSON) {
//        count = play["count"].intValue
//        next = play["next"].url
//        previous = play["previous"].url
//        
//        if let resultSongs = play["results"].array {
//            var theSongs = [Song]()
//            
//            for song in resultSongs {
//                 theSongs.append(Song(song))
//            }
//            
//            songs = theSongs
//        }
//        else {
//            songs = nil
//        }
//    }
//}
