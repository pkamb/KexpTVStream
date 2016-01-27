//
//  KexpConfigSettings.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import UIKit
import SwiftyJSON

class KexpConfigSettings {
    let streamUrl: String?
    let backupStreamUrl: String?
    let nowPlayingLogo: String?
    let updated: Int?
    
    init(configSettingJSON: JSON) {
        streamUrl = configSettingJSON["kexpStreamUrl"].string
        backupStreamUrl = configSettingJSON["kexpBackupStreamUrl"].string
        nowPlayingLogo = configSettingJSON["kexpNowPlayingLogo"].string
        updated = configSettingJSON["updated"].int
    }
}
