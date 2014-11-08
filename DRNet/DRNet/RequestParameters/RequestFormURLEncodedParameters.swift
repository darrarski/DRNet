//
//  RequestFormURLEncodedParameters.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 21/10/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class RequestFormURLEncodedParameters: RequestQueryStringParameters {
    
    // MARK: - RequestParameters protocol
    
    override public func setParametersInRequest(request: NSURLRequest) -> NSURLRequest {
        var mutableURLRequest: NSMutableURLRequest! = request.mutableCopy() as NSMutableURLRequest
        setParametersInRequest(mutableURLRequest)
        
        return request.copy() as NSURLRequest
    }
    
    override public func setParametersInRequest(request: NSMutableURLRequest) {
        if request.valueForHTTPHeaderField("Content-Type") == nil {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        if let data = query(parameters).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
            request.HTTPBody = data
        }
        else {
            assertionFailure("Unable to set Form URL Encoded parameters in request")
        }
    }
    
}