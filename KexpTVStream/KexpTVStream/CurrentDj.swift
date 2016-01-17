//
//  CurrentDj.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit

class CurrentDj {
    var djFirstName: String?
    var djName: String?
    var showTitle: String?
    var showType: String?
    
    init(currentDjDictionary: Dictionary<String, AnyObject>) {
        djFirstName = currentDjDictionary["DJFirstName"] as? String
        djName = currentDjDictionary["DJName"] as? String
        showTitle = currentDjDictionary["Title"] as? String
        showType = currentDjDictionary["Subtitle"] as? String
    }
}
