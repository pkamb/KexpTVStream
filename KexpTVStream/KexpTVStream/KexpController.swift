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

typealias TrackChangeBlock = (nowplaying: NowPlaying?) -> Void
typealias DJChangeBlock = (currentDjInfo: CurrentDj?) -> Void
typealias ConfigurationSettingsBlock = (kexpConfig: KexpConfigSettings) -> Void

private let kexpNowPlayingURL = "http://www.kexp.org/s/s.aspx?x=3"
private let kexpCurrentDJURL = "http://www.kexp.org/s/s.aspx?x=5"
private let kexpConfigURL = "http://www.kexp.org/content/applications/AppleTV/config/KexpConfigResponse.json"

class KexpController {

   class func getNowPlayingInfo(currentTrackUpdate: TrackChangeBlock) {
        Alamofire.request(.GET, kexpNowPlayingURL, parameters: nil)
            .responseJSON { response in
                guard let jsonResponse = response.result.value else { currentTrackUpdate(nowplaying: nil); return }
                
                let nowPlayingResponse = JSON(jsonResponse)
                let nowPlaying = NowPlaying(nowPlayingJSON: nowPlayingResponse)
                print(nowPlayingResponse)
                currentTrackUpdate(nowplaying: nowPlaying)
        }
    }
    
    class func getDjInfo(currentDjUpdate: DJChangeBlock) {
        Alamofire.request(.GET, kexpCurrentDJURL, parameters: nil)
            .responseJSON { response in
                guard let jsonResponse = response.result.value else { currentDjUpdate(currentDjInfo: nil); return }
                
                let currentDJResponse = JSON(jsonResponse)
                let djInfo = CurrentDj(currentDjJSON: currentDJResponse)
                currentDjUpdate(currentDjInfo: djInfo)
        }
    }
    
    class func getKEXPConfig(configurationSetup: ConfigurationSettingsBlock) {
        guard let url = NSURL(string: kexpConfigURL) else { return }
        guard let kexpConfigData = NSData(contentsOfURL: url) else { return }

        let configJSON = JSON(data: kexpConfigData)
        let configSetting = KexpConfigSettings(configSettingJSON: configJSON)
        configurationSetup(kexpConfig: configSetting)
    }
}
