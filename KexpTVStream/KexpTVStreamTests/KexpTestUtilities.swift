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
    
    class func getJSONFromTestFile(_ testFileName: String)  -> JSON? {
        let filePath = Bundle.main.path(forResource:testFileName, ofType: "json")
        
        if let fPath = filePath {
            
            let content = try! Data(contentsOf: URL(string: fPath)!)
            
           // if let jsonContent = content {
                let json = JSON(data: content)
                
                return json
          //  }
        }
        
        return nil
    }
}
