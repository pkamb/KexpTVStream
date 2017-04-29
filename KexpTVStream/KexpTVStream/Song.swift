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
    let airdate: Date
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

    public init(_ song: JSON) {
        playId = song["playid"].intValue
        playTypeId = song["playtype"]["playtypeid"].intValue
        playTypeName = song["playtype"]["name"].stringValue
        airdate = song["airdate"].date ?? Date()
        artistId = song["artist"]["artistid"].int
        artistName = song["artist"]["name"].string
        isLocal = song["artist"]["islocal"].bool
        releaseId = song["release"]["releaseid"].int
        releaseName = song["release"]["name"].string
        largeImageUrl = song["release"]["largeimageuri"].url
        smallImageUrl = song["release"]["smallimageuri"].url
        trackId = song["track"]["trackid"].int
        trackName = song["track"]["name"].string
        releaseEventId = song["releaseevent"]["releaseeventid"].int
        releaseEventYear = song["releaseevent"]["year"].int
        labelId = song["label"]["labelid"].int
        labelName = song["label"]["name"].string

        if let songComments = song["comments"].array {
            var theComments = [Comment]()
            
            for comment in songComments {
                theComments.append(Comment(comment))
            }
            
            comments = theComments
        }
        else {
            comments = nil
        }
    }
}
