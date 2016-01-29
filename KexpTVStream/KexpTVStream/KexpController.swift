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
typealias ConfigurationSettingsBlock = (kexpConfig: KexpConfigSettings) -> Void

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
    
    class func getKEXPConfig(configurationSetup: ConfigurationSettingsBlock) {
        let configSetting:KexpConfigSettings?
        
        if let url = NSURL(string: kexpConfigURL) {
            let kexpConfigData = NSData(contentsOfURL: url)
            
            if let kexpConfigData = kexpConfigData {
                let configJSON = JSON(data: kexpConfigData)
                configSetting = KexpConfigSettings(configSettingJSON: configJSON)
            }
            else {
                configSetting = KexpConfigSettings(configSettingJSON: nil)
            }
            
            if let configSetting = configSetting {
                configurationSetup(kexpConfig: configSetting)
            }
        }
    }
}
