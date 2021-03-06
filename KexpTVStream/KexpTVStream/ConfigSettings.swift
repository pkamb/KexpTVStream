//
//  KexpConfigSettings.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import UIKit
import SwiftyJSON

private let kexpStreamUrl = "https://kexp-mp3-128.streamguys1.com/kexp128.mp3"
private let kexpBackupStreamUrl = "https://live-aacplus-64.streamguys1.com/kexp64.aac"

class ConfigSettings {
    let streamUrl: String?
    let backupStreamUrl: String?
    let nowPlayingLogo: String?
    let updated: Int?
    
    init(_ configSettingJSON: JSON?) {
        if let configSettingJSON = configSettingJSON {
            streamUrl = configSettingJSON["kexpStreamUrl"].string
            backupStreamUrl = configSettingJSON["kexpBackupStreamUrl"].string
            nowPlayingLogo = configSettingJSON["kexpNowPlayingLogo"].string
            updated = configSettingJSON["updated"].int
        }
        else {
            streamUrl = kexpStreamUrl
            backupStreamUrl = kexpBackupStreamUrl
            nowPlayingLogo = ""
            updated = 0
        }
    }
}
