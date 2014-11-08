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
        let provider = DRNet.URLCacheProvider(memoryCapacity: 1024, diskCapacity: 2048, diskPath: "Test")
        
        XCTAssert(provider.memoryCapacity == 1024, "Invalid memory capacity")
        XCTAssert(provider.diskCapacity == 2048, "Invalid disk capacity")
        XCTAssert(provider.diskPath == "Test", "Invalid disk path")
    }
    
}
