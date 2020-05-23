//
//  UIColor+Theme.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 5/23/20.
//  Copyright © 2020 Dustin Bergman. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init?(hexString: String) {
         var chars = Array(hexString.hasPrefix("#") ? hexString.dropFirst() : hexString[...])
         switch chars.count {
         case 3: chars = chars.flatMap { [$0, $0] }; fallthrough
         case 6: chars = ["F","F"] + chars
         case 8: break
         default: return nil
         }
        
         self.init(red: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 green: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                  blue: .init(strtoul(String(chars[6...7]), nil, 16)) / 255,
                 alpha: .init(strtoul(String(chars[0...1]), nil, 16)) / 255)
     }

    class func kexpOrange() -> UIColor {
        return UIColor(hexString: "#FEAC30")!
    }
    
    class func darkGray() -> UIColor {
        return UIColor(hexString: "#2F4F4F")!
    }
}


    

    
