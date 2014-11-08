//
//  RequestStandardHeaders.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

class RequestStandardHeaders: RequestHeaders {
    
    let headers: [String: String]
    let append: Bool = false
    
    init(_ headers: [String: String], append: Bool? = nil) {
        self.headers = headers
        if let append = append {
            self.append = append
        }
    }
    
    // MARK: - RequestParameters protocol
    
    func setHeadersInRequest(request: NSURLRequest) -> NSURLRequest {
        var mutableURLRequest: NSMutableURLRequest! = request.mutableCopy() as NSMutableURLRequest
        setHeadersInRequest(mutableURLRequest)
        
        return request.copy() as NSURLRequest
    }
    
    func setHeadersInRequest(request: NSMutableURLRequest) {
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