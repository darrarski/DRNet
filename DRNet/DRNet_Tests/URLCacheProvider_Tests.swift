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
    
}
