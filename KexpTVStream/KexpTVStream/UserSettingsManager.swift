//
//  UserSettingsManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/4/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import KEXPPower

struct UserSettingsManager {
    enum SettingKey: String {
        case disableIdleTimer
    }
    
    static private let defaults = UserDefaults.standard

    static var disableTimer: Bool {
        set {
            defaults.set(newValue, forKey: SettingKey.disableIdleTimer.rawValue)
        }
        
        get {
            return defaults.bool(forKey: SettingKey.disableIdleTimer.rawValue)
        }
    }
}
