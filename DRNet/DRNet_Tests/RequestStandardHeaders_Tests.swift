//
//  RequestStandardHeaders_Tests.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 22/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OS_X)
    import Cocoa
#endif

import XCTest
import DRNet

class RequestStandardHeaders_Tests: XCTestCase {
    
    func testSetRequestHeaders() {
        let headerValues = [
            "header1": "value1",
            "header2": "value2",
            "header3": "value3"
        ]
        
        let headers = DRNet.RequestStandardHeaders(headerValues)
        let request = DRNet.Request(method: .GET, url: NSURL(string: "")!, headers: headers, parameters: nil)
        let urlRequest = request.toNSURLRequest()
        
        for (key, value) in headerValues {
            if let setValue = urlRequest.valueForHTTPHeaderField(key) {
                XCTAssertEqual(setValue, value, "Invalid header value")
            }
            else {
                XCTFail("Empty header value for key \"\(key)\"")
            }
        }
    }
    
}
