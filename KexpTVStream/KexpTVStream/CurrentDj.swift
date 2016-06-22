//
//  CurrentDj.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 12/27/15.
//  Copyright © 2015 Dustin Bergman. All rights reserved.
//

import UIKit
import SwiftyJSON

class CurrentDj {
    var djFirstName: String?
    var djName: String?
    var showTitle: String?
    var showType: String?
    
    init(currentDjJSON: JSON?) {
        guard let currentDjJSON = currentDjJSON else { return }
        
        djFirstName = currentDjJSON["DJFirstName"].string
        djName = currentDjJSON["DJName"].string
        showTitle = currentDjJSON["Title"].string
        showType = currentDjJSON["Subtitle"].string
    }
}
