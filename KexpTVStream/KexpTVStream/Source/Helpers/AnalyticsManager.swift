//
//  AnalyticsManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 6/4/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import Flurry_iOS_SDK
import KEXPPower

struct AnalyticsManager {
    enum Event {
        case startLiveStream(Show)
        case startArchiveStream(Show)
        case archiveShowJumpToTime(Show, String)
        case disableIdleTimer(Bool)
    }
    
    static func fire(_ event: Event) {
        switch event {
        case .startLiveStream(let liveShow):
            Flurry.logEvent("Start_Live_Stream", withParameters: showDetails(with: liveShow))
        case .startArchiveStream(let archiveShow):
            Flurry.logEvent("Start_Archive_Stream", withParameters: showDetails(with: archiveShow))
        case .archiveShowJumpToTime(let archiveShow, let startTime):
            var details = showDetails(with: archiveShow)
            details["StartTime"] = startTime
            Flurry.logEvent("Archive_Jump_To_Time", withParameters: details)
        case .disableIdleTimer(let isDisabled):
            let event = isDisabled ? "Idle_Timer_Disabled" : "Idle_Timer_Enabled"
            Flurry.logEvent(event)
        }
    }
    
    private static func showDetails(with show: Show) -> [String: String] {
        var details = [String: String]()
    
        if let show = show.programName {
            details["Show"]  = show
        }
        
        if let hosts = show.hostNames?.joined(separator: ", ") {
            details["Host"]  = hosts
        }
    
        if let showDate = show.startTime {
            details["Date"]  = DateFormatter.nowPlayingFormatter.string(from: showDate)
        }
        
        return details
    }
}
