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
    let djFirstName: String?
    let djName: String?
    let showTitle: String?
    let showType: String?
    
    init(currentDjJSON: JSON) {
        djFirstName = currentDjJSON["DJFirstName"].string
        djName = currentDjJSON["DJName"].string
        showTitle = currentDjJSON["Title"].string
        showType = currentDjJSON["Subtitle"].string
    }
}
