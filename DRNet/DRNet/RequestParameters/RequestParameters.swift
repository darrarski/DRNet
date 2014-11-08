//
//  RequestParameters.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 21/10/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public protocol RequestParameters {
    
    func setParametersInRequest(request: NSURLRequest) -> NSURLRequest
    func setParametersInRequest(request: NSMutableURLRequest)
    
}