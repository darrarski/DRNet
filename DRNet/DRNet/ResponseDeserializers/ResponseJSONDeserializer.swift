//
//  ResponseJSONDeserializer.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

class ResponseJSONDeserializer: ResponseDeserializer {
    
    let options: NSJSONReadingOptions = .allZeros
    
    init(options: NSJSONReadingOptions? = nil) {
        if let options = options {
            self.options = options
        }
    }
    
    // MARK: ResponseDeserializer protocol
    
    func deserializeResponseData(response: Response) -> (deserializedData: AnyObject?, errors: [NSError]?) {
        var deserializedData: AnyObject?
        var errors: [NSError] = []
        
        if let responseData = response.data {
            var error: NSError?
            if let JSONObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(responseData, options: options, error: &error) {
                deserializedData = JSONObject
            }
            if let error = error {
                errors.append(error)
            }
        }
        
        return (
            deserializedData: deserializedData,
            errors: errors.count > 0 ? errors : nil
        )
    }
    
}