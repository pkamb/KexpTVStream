//
//  KexpTestUtilities.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import UIKit
import SwiftyJSON

class KexpTestUtilities {
    
    class func getJSONFromTestFile(testFileName: String)  -> JSON? {
        let filePath = NSBundle.mainBundle().pathForResource(testFileName, ofType: "json")
        if let fPath = filePath {
            let content = NSData(contentsOfFile: fPath)
            
            if let jsonContent = content {
                let json = JSON(data: jsonContent)
                
                return json
            }
        }
        
        return nil
    }
}
