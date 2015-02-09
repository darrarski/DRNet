//
//  Request.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class Request {
    
    public enum Method: String {
        case GET = "GET"
        case PUT = "PUT"
        case POST = "POST"
        case DELETE = "DELETE"
        case PATCH = "PATCH"
        
        public static let allMethods: [Method] = [.GET, .PUT, .POST, .DELETE, .PATCH]
    }
    
    public let method: Method
    public let url: NSURL
    public let headers: RequestHeaders?
    public let parameters: RequestParameters?
    
    public init(method: Method, url: NSURL, headers: RequestHeaders? = nil, parameters: RequestParameters? = nil) {
        self.method = method
        self.url = url
        self.headers = headers
        self.parameters = parameters
    }
    
    public func toNSURLRequest() -> NSURLRequest {
        var request = NSMutableURLRequest()
        
        request.HTTPMethod = method.rawValue
        request.URL = url
        headers?.setHeadersInRequest(request)
        parameters?.setParametersInRequest(request)
        
        return request.copy() as! NSURLRequest
    }
    
}