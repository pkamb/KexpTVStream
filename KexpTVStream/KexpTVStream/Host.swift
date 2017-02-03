//
//  Host.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 2/2/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

import SwiftyJSON

public struct Host {
    let hostId: Int?
    let hostName: String?
    let hostImageUrl: URL?
    
    public init(_ host: JSON) {
        hostId = host["hostid"].int
        hostName = host["name"].string
        hostImageUrl = host["imageuri"].url
    }
}
