//
//  Response.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class Response: NSObject, NSCoding {
    
    public let URLResponse: NSURLResponse?
    public let data: NSData?
    public let error: NSError?
    public let URLRequest: NSURLRequest?
    
    public init(URLResponse: NSURLResponse?, data: NSData?, error: NSError?, forURLRequest: NSURLRequest?) {
        self.URLResponse = URLResponse
        self.data = data
        self.error = error
        self.URLRequest = forURLRequest
    }
    
    // MARK: - NSCoding
    
    public required convenience init(coder aDecoder: NSCoder) {
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
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(URLResponse, forKey: "URLResponse")
        aCoder.encodeObject(data, forKey: "data")
        aCoder.encodeObject(error, forKey: "error")
        aCoder.encodeObject(URLRequest, forKey: "URLRequest")
    }
    
}