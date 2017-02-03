//
//  Show.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 2/2/17.
//  Copyright © 2017 Dustin Bergman. All rights reserved.
//

import SwiftyJSON

public struct Show {
    let showId: Int
    let programId: Int?
    let showName: String?
    let showDescription: String?
    let airdate: String
    let tagline: String?
    let hosts: [Host]?
    
    public init(_ theShow: JSON) {
        showId = theShow["showid"].intValue
        programId = theShow["program"]["programid"].int
        showName = theShow["program"]["name"].string
        showDescription = theShow["program"]["description"].string
        airdate = theShow["airdate"].stringValue
        tagline = theShow["tagline"].string
        
        if let hostsResponse = theShow["hosts"].array {
            var theHosts = [Host]()
            
            for host in hostsResponse {
                theHosts.append(Host(host))
            }
            
            hosts = theHosts
        }
        else {
            hosts = nil
        }
    }
}
