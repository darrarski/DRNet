//
//  Request_Tests.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 09/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#if os(iOS)
    import UIKit
    #elseif os(OS_X)
    import Cocoa
#endif

import XCTest
import DRNet

class Request_Tests: XCTestCase {
    
    func testInitWithVariousMethods() {
        for method in DRNet.Request.Method.allMethods {
            testInit(method: method, url: NSURL(string: "http://test/" + method.rawValue)!, headers: nil, parameters: nil)
        }
    }
    
    func testInit(#method: DRNet.Request.Method, url: NSURL, headers: DRNet.RequestHeaders? = nil, parameters: DRNet.RequestParameters? = nil) {
        let request = DRNet.Request(method: method, url: url, headers: headers, parameters: parameters)
        
        XCTAssert(request.method == method, "Invalid request method")
        XCTAssert(request.url.absoluteString == url.absoluteString, "Invalid request url")
    }
    
}