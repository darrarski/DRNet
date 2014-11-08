//
//  Request.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

class Request {
    
    enum Method: String {
        case GET = "GET"
        case PUT = "PUT"
        case POST = "POST"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
    }
    
    let method: Method
    let url: NSURL
    let headers: RequestHeaders?
    let parameters: RequestParameters?
    
    init(method: Method, url: NSURL, headers: RequestHeaders? = nil, parameters: RequestParameters? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parameters = parameters
    }
    
    func toNSURLRequest() -> NSURLRequest {
        var request = NSMutableURLRequest()
        
        request.HTTPMethod = method.rawValue
        request.URL = url
        headers?.setHeadersInRequest(request)
        parameters?.setParametersInRequest(request)
        
        return request.copy() as NSURLRequest
    }
    
}