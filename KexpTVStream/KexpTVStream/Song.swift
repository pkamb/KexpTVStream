//
//  Song.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/30/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

import SwiftyJSON

public struct Song {
    let playId: Int
    let playTypeId: Int
    let playTypeName: String
    let airdate: String
    let artistId: Int?
    let artistName: String?
    let isLocal: Bool?
    let releaseId: Int?
    let releaseName: String?
    let largeImageUrl: URL?
    let smallImageUrl: URL?
    let releaseEventId: Int?
    let releaseEventYear: Int?
    let trackId: Int?
    let trackName: String?
    let labelId: Int?
    let labelName: String?
    let comments: [Comment]?

    public init(currentSong: JSON) {
        playId = currentSong["playid"].intValue
        playTypeId = currentSong["playtype"]["playtypeid"].intValue
        playTypeName = currentSong["playtype"]["name"].stringValue
        airdate = currentSong["airdate"].stringValue
        artistId = currentSong["artist"]["artistid"].int
        artistName = currentSong["artist"]["name"].string
        isLocal = currentSong["artist"]["islocal"].bool
        releaseId = currentSong["release"]["releaseid"].int
        releaseName = currentSong["release"]["name"].string
        largeImageUrl = currentSong["release"]["largeimageuri"].url
        smallImageUrl = currentSong["release"]["smallimageuri"].url
        trackId = currentSong["track"]["trackid"].int
        trackName = currentSong["track"]["name"].string
        releaseEventId = currentSong["releaseevent"]["releaseeventid"].int
        releaseEventYear = currentSong["releaseevent"]["year"].int
        labelId = currentSong["label"]["labelid"].int
        labelName = currentSong["label"]["name"].string

        if let songComments = currentSong["comments"].array {
            var theComments = [Comment]()
            
            for comment in songComments {
                theComments.append(Comment(comment: comment))
            }
            
            comments = theComments
        }
        else {
            comments = nil
        }

    }
}
