//
//  KexpTestUtilities.swift
//  KexpTVStream
//
//  Created by Dustin Bergman on 1/17/16.
//  Copyright © 2016 Dustin Bergman. All rights reserved.
//

import UIKit

class KexpTestUtilities {
    
    class func getJSONFromTestFile(testFileName: String) -> Dictionary<String, AnyObject>{
        let filePath = NSBundle.mainBundle().pathForResource(testFileName, ofType: "json")
        if let fPath = filePath {
            let content = NSData(contentsOfFile: fPath)
            
            do {
                if let jsonContent = content {
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(jsonContent, options:NSJSONReadingOptions.AllowFragments) as? Dictionary<String, AnyObject>
                    
                    return jsonDictionary ?? Dictionary<String, AnyObject>()
                }
            }
            catch let error as NSError {
                print("A JSON parsing error occurred, here are the details:\n \(error)")
            }
        }
        
        return Dictionary<String, AnyObject>()
    }
}
