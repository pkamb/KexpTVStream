//
//  ThemeManager.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/13/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

struct ThemeManager {
    static func kexpBackgroundGradient() -> CAGradientLayer {
        let colorTop = KexpStyle.kexpOrange().cgColor
        let colorBottom = UIColor.white.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        
        return gradientLayer
    }
    
    enum TabBar {
        static let font = UIFont(name: "KohinoorTelugu-Medium", size: 32)
    }
    
    enum Settings {
        static let font = UIFont(name: "KohinoorTelugu-Medium", size: 32)
        static let textColor = UIColor.black
    }
    
    struct Archive {
        enum Menu {
            static let font = UIFont(name: "KohinoorTelugu-Medium", size: 32)
            static let textColor = UIColor.black
        }
        
        enum Select {
            static let font = UIFont(name: "KohinoorTelugu-Medium", size: 32)
            static let textColor = UIColor.black
        }
        
        struct Calander {
            enum Month {
                static let font = UIFont(name: "KohinoorTelugu-Regular", size: 28)
                static let textColor = UIColor.black
            }
            
            enum Day {
                static let font = UIFont(name: "KohinoorTelugu-Medium", size: 60)
                static let textColor = UIColor.black
            }
            
            enum DayOfWeek {
                static let font = UIFont(name: "KohinoorTelugu-Regular", size: 28)
                static let textColor = UIColor.black
            }
        }
    }
    
    struct ShowDetails {
        enum ShowTitle {
            static let font = UIFont(name: "KohinoorTelugu-Medium", size: 28)
            static let textColor = UIColor.black
        }
        
        enum ArchiveDate {
            static let font = UIFont(name: "KohinoorTelugu-Light", size: 22)
            static let textColor = UIColor.darkGray()
        }
    }
    
    struct NowPlaying {
        enum ListenLive {
            static let font = UIFont(name: "KohinoorTelugu-Medium", size: 30)
            static let textColor = UIColor.black
        }
        
        enum Track {
            static let font = UIFont(name: "KohinoorTelugu-Medium", size: 30)
            static let textColor = UIColor.black
        }
        
        enum TimeStamp {
            static let font = UIFont(name: "KohinoorTelugu-Light", size: 22)
            static let textColor = UIColor.darkGray()
        }
        
        enum Artist {
            static let font = UIFont(name: "KohinoorTelugu-Regular", size: 26)
            static let textColor = UIColor.black
        }
        
        enum Album {
            static let font = UIFont(name: "KohinoorTelugu-Regular", size: 22)
            static let textColor = UIColor.black
        }
        
        enum Release {
            static let font = UIFont(name: "KohinoorTelugu-Light", size: 23)
            static let textColor = UIColor.darkGray()
        }
    }
}
