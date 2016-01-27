//
//  File.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/23/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import Alamofire

typealias TrackChangeBlock = (nowplaying: NowPlaying) -> Void
typealias DJChangeBlock = (currentDjInfo: CurrentDj) -> Void

private let kexpNowPlayingURL = "http://www.kexp.org/s/s.aspx?x=3"
private let kexpCurrentDJURL = "http://www.kexp.org/s/s.aspx?x=5"

class KexpController {

   class func getNowPlayingInfo(currentTrackUpdate: TrackChangeBlock) {
        Alamofire.request(.GET, kexpNowPlayingURL, parameters: [:])
            .responseJSON { response in
                if let nowplayingResponse = response.result.value as? [String:AnyObject] {
                    let nowPlaying = NowPlaying(nowPlayingDictionary: nowplayingResponse)
                    print(nowplayingResponse)
                    currentTrackUpdate(nowplaying: nowPlaying)
                }
        }
    }
    
    class func getDjInfo(currentDjUpdate: DJChangeBlock) {
        Alamofire.request(.GET, kexpCurrentDJURL, parameters: [:])
            .responseJSON { response in
                if let currentDJResponse = response.result.value as? [String:AnyObject] {
                    let djInfo = CurrentDj(currentDjDictionary: currentDJResponse)
                    currentDjUpdate(currentDjInfo: djInfo)
                }
        }
    }
}