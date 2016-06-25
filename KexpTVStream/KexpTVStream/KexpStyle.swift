//
//  KexpStyle.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit

let KexpOrangeColorHex = "#FEAC30"

struct FontSizes {
    static let xxsmall = CGFloat(16.0)
    static let xsmall = CGFloat(24.0)
    static let small = CGFloat(38.0)
    static let medium = CGFloat(46.0)
    static let large = CGFloat(56.0)
    static let xLarge = CGFloat(66.0)
    static let xxLarge = CGFloat(96.0)
}

class KexpStyle {
    class func kexpOrange() -> UIColor {
        return colorWithHexString(KexpOrangeColorHex)
    }
    
    class func kexpBackgroundGradient () -> CAGradientLayer {
        let colorTop = KexpStyle.kexpOrange().CGColor
        let colorBottom = UIColor.whiteColor().CGColor
        
        let gl = CAGradientLayer()
        gl.colors = [ colorTop, colorBottom]
        gl.locations = [ 0.0, 1.0]
        
        return gl
    }
    
    class func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
}
