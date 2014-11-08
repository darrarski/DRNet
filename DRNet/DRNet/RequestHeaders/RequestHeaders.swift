//
//  RequestHeaders.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public protocol RequestHeaders {
    
    func setHeadersInRequest(request: NSURLRequest) -> NSURLRequest
    func setHeadersInRequest(request: NSMutableURLRequest)
    
}