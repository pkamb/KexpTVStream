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
        case archiveLastUpdated
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
    
    static var archiveFetchDate: Date {
        set {
            defaults.set(Date(), forKey: SettingKey.archiveLastUpdated.rawValue)
        }
        
        get {
            if let date =  defaults.object(forKey: SettingKey.archiveLastUpdated.rawValue) as? Date {
                return date
            }
            
            return Date()
        }
    }
}
