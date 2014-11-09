//
//  URLCacheProvider_Tests.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 08/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

#if os(iOS)
    import UIKit
#elseif os(OS_X)
    import Cocoa
#endif

import XCTest
import DRNet

class URLCacheProvider_Tests: XCTestCase {
    
    func testInit() {
        let provider = DRNet.URLCacheProvider(memoryCapacity: .Limit(bytes: 1024), diskCapacity: .Limit(bytes: 2048), diskPath: "TestPath")
        
        switch provider.memoryCapacity {
        case .Limit(bytes: 1024): ()
        default:
            XCTFail("Invalid memory capacity")
        }
        
        switch provider.diskCapacity {
        case .Limit(bytes: 2048): ()
        default:
            XCTFail("Invalid disk capacity")
        }
        
        XCTAssert(provider.diskPath == "TestPath", "Invalid disk path")
    }
    
    func testSaveAndFetchFromMemory() {
        testSaveAndFetch(DRNet.URLCacheProvider(memoryCapacity: .Limit(bytes: 10 * 1024), diskCapacity: .Disable, diskPath: "Test"))
    }
    
    func testSaveAndFetchFromDisk() {
        testSaveAndFetch(DRNet.URLCacheProvider(memoryCapacity: .Disable, diskCapacity: .Limit(bytes: 10 * 1024), diskPath: "Test"))
    }
    
    private func testSaveAndFetch(provider: DRNet.URLCacheProvider) {
        let request = DRNet.Request(method: .GET, url: NSURL(string: "http://test")!, headers: nil, parameters: nil)
        let responseDataString = "ResponseTest"
        let responseData = responseDataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let response = DRNet.Response(URLResponse: nil, data: responseData, error: nil, forURLRequest: request.toNSURLRequest())
        
        provider.saveResponse(response, forRequest: request)
        
        let expectProviderReturnsCachedResponse = expectationWithDescription("provider returns cached response")
        
        provider.responseForRequest(request, completion: { (cachedResponse) -> Void in
            if let cachedResponseData = cachedResponse.data {
                if let cachedResponseDataString = NSString(data: cachedResponseData, encoding: NSUTF8StringEncoding) {
                    XCTAssert(cachedResponseDataString == responseDataString, "cached response data string differs from response data string")
                }
                else {
                    XCTFail("cached response data cannot be converted to string")
                }
            }
            else {
                XCTFail("cached response data is empty")
            }
            
            expectProviderReturnsCachedResponse.fulfill()
        })
        
        waitForExpectationsWithTimeout(3, handler: { (error) -> Void in })
    }
    
}
