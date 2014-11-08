//
//  RequestStandardHeaders.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class RequestStandardHeaders: RequestHeaders {
    
    public let headers: [String: String]
    public let append: Bool = false
    
    public init(_ headers: [String: String], append: Bool? = nil) {
        self.headers = headers
        if let append = append {
            self.append = append
        }
    }
    
    // MARK: - RequestParameters protocol
    
    public func setHeadersInRequest(request: NSURLRequest) -> NSURLRequest {
        var mutableURLRequest: NSMutableURLRequest! = request.mutableCopy() as NSMutableURLRequest
        setHeadersInRequest(mutableURLRequest)
        
        return request.copy() as NSURLRequest
    }
    
    public func setHeadersInRequest(request: NSMutableURLRequest) {
        for (key, value) in headers {
            if append {
                request.addValue(value, forHTTPHeaderField: key)
            }
            else {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
    }
    
}