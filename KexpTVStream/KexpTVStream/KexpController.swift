//
//  File.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/23/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

typealias TrackChangeBlock = (nowplaying: NowPlaying) -> Void
typealias DJChangeBlock = (currentDjInfo: CurrentDj) -> Void

private let kexpNowPlayingURL = "http://www.kexp.org/s/s.aspx?x=3"
private let kexpCurrentDJURL = "http://www.kexp.org/s/s.aspx?x=5"
private let kexpConfigURL = "http://www.kexp.org/content/applications/AppleTV/config/KexpConfigResponse.json"

class KexpController {

   class func getNowPlayingInfo(currentTrackUpdate: TrackChangeBlock) {
        Alamofire.request(.GET, kexpNowPlayingURL).response { (req, res, data, error) -> Void in
                if let jsonData = data {
                    let nowPlayingJSON = JSON(data: jsonData)
                    let nowPlaying = NowPlaying.init(nowPlayingJSON: nowPlayingJSON)
                    
                    currentTrackUpdate(nowplaying: nowPlaying)
               }
        }
    }
    
    class func getDjInfo(currentDjUpdate: DJChangeBlock) {
        Alamofire.request(.GET, kexpCurrentDJURL).response { (req, res, data, error) -> Void in
                if let jsonData = data {
                    let currentDJJSON = JSON(data: jsonData)
                    let djInfo = CurrentDj(currentDjJSON: currentDJJSON)
                    
                    currentDjUpdate(currentDjInfo: djInfo)
                }
        }
    }
    
    class func getKEXPConfig() {
        Alamofire.request(.GET, kexpConfigURL).response { (req, res, data, error) -> Void in
            if let jsonData = data {
                let configJSON = JSON(data: jsonData)
                let configSetting = KexpConfigSettings(configSettingJSON: configJSON)
                
                print(configSetting)
            }
        }
    }
}
