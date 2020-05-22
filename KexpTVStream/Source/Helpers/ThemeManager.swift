//
//  ThemeManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/13/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

struct ThemeManager {
    enum Track {
        static let font = UIFont(name: "KohinoorTelugu-Medium", size: 32)
        static let textColor = UIColor.black
    }
    
    enum TimeStamp {
        static let font = UIFont(name: "KohinoorTelugu-Light", size: 22)
        static let textColor = UIColor.lightGray
    }
    
    enum Artist {
        static let font = UIFont(name: "KohinoorTelugu-Regular", size: 28)
        static let textColor = UIColor.black
    }
    
    enum Album {
        static let font = UIFont(name: "KohinoorTelugu-Regular", size: 22)
        static let textColor = UIColor.black
    }
    
    enum Release {
        static let font = UIFont(name: "KohinoorTelugu-Light", size: 23)
        static let textColor = UIColor.lightGray
    }
}
