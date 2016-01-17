//
//  KexpConfigSettings.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import UIKit

class KexpConfigSettings: NSObject {
    var streamUrl: String?
    var backupStreamUrl: String?
    var nowPlayingLogo: String?
    var updated: Int?
    
    init(configSettingDictionary: Dictionary<String, AnyObject>) {
        streamUrl = configSettingDictionary["kexpStreamUrl"] as? String
        backupStreamUrl = configSettingDictionary["kexpBackupStreamUrl"] as? String
        nowPlayingLogo = configSettingDictionary["kexpNowPlayingLogo"] as? String
        updated = configSettingDictionary["updated"] as? Int
    }
}
