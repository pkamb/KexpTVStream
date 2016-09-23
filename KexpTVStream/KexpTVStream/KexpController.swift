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

typealias TrackChangeBlock = (_ nowplaying: NowPlaying?) -> Void
typealias DJChangeBlock = (_ currentDjInfo: CurrentDj?) -> Void
typealias ConfigurationSettingsBlock = (_ kexpConfig: KexpConfigSettings) -> Void

private let kexpNowPlayingURL = "http://www.kexp.org/s/s.aspx?x=3"
private let kexpCurrentDJURL = "http://www.kexp.org/s/s.aspx?x=5"
private let kexpConfigURL = "http://www.kexp.org/content/applications/AppleTV/config/KexpConfigResponse.json"

class KexpController {

   class func getNowPlayingInfo(_ currentTrackUpdate: @escaping TrackChangeBlock) {
        Alamofire.request(kexpNowPlayingURL)
            .responseJSON { response in
                guard let jsonResponse = response.result.value else { currentTrackUpdate(nil); return }
                
                let nowPlayingResponse = JSON(jsonResponse)
                let nowPlaying = NowPlaying(nowPlayingJSON: nowPlayingResponse)
                print(nowPlayingResponse)
                currentTrackUpdate(nowPlaying)
        }
    }
    
    class func getDjInfo(_ currentDjUpdate: @escaping DJChangeBlock) {
        Alamofire.request(kexpCurrentDJURL)
            .responseJSON { response in
                guard let jsonResponse = response.result.value else { currentDjUpdate(nil); return }
                
                let currentDJResponse = JSON(jsonResponse)
                let djInfo = CurrentDj(currentDjJSON: currentDJResponse)
                currentDjUpdate(djInfo)
        }
    }
    
    class func getKEXPConfig(_ configurationSetup: ConfigurationSettingsBlock) {
        guard let url = URL(string: kexpConfigURL) else { return }
        guard let kexpConfigData = try? Data(contentsOf: url) else {
            let configSetting = KexpConfigSettings(configSettingJSON: nil)
            configurationSetup(configSetting)
            return
        }

        let configJSON = JSON(data: kexpConfigData)
        let configSetting = KexpConfigSettings(configSettingJSON: configJSON)
        configurationSetup(configSetting)
    }
}
