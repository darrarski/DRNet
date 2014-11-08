//
//  Response.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

class Response: NSObject, NSCoding {
    
    let URLResponse: NSURLResponse?
    let data: NSData?
    let error: NSError?
    let URLRequest: NSURLRequest?
    
    init(URLResponse: NSURLResponse?, data: NSData?, error: NSError?, forURLRequest: NSURLRequest?) {
        self.URLResponse = URLResponse
        self.data = data
        self.error = error
        self.URLRequest = forURLRequest
    }
    
    // MARK: - NSCoding
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(
            URLResponse: {
                return aDecoder.decodeObjectForKey("URLResponse") as? NSURLResponse
            }(),
            data: {
                return aDecoder.decodeObjectForKey("data") as? NSData
            }(),
            error: {
                return aDecoder.decodeObjectForKey("error") as? NSError
            }(),
            forURLRequest: {
                return aDecoder.decodeObjectForKey("URLRequest") as? NSURLRequest
            }()
        )
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(URLResponse, forKey: "URLResponse")
        aCoder.encodeObject(data, forKey: "data")
        aCoder.encodeObject(error, forKey: "error")
        aCoder.encodeObject(URLRequest, forKey: "URLRequest")
    }
    
}