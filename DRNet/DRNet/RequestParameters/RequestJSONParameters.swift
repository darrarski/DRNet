//
//  RequestJSONParameters.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 21/10/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class RequestJSONParameters: RequestParameters {
    
    public let parameters: [String: AnyObject]
    
    public init(_ parameters: [String: AnyObject]) {
        self.parameters = parameters
    }
    
    // MARK: - RequestParameters protocol
    
    public func setParametersInRequest(request: NSURLRequest) -> NSURLRequest {
        var mutableURLRequest: NSMutableURLRequest! = request.mutableCopy() as! NSMutableURLRequest
        setParametersInRequest(mutableURLRequest)
        
        return request.copy() as! NSURLRequest
    }
    
    public func setParametersInRequest(request: NSMutableURLRequest) {
        assert(request.HTTPMethod != "GET", "Submitting HTTP Body with JSON parameters is not supported for GET requests")
        
        var error: NSError?
        if let data = NSJSONSerialization.dataWithJSONObject(parameters, options: .allZeros, error: &error) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = data
        }
        
        if let error = error {
            assertionFailure("Unable to set JSON parameters in request due to error: \(error.localizedDescription)")
        }
    }
    
}