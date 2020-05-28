//
//  DisplayFormatters.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 4/14/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import Foundation

extension DateFormatter {
    public static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    public static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    public static let dayOfWeekFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    public static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    public static let releaseFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    public static let nowPlayingFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    
}
