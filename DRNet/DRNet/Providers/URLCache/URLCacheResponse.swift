//
//  URLCacheResponse.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 05/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class URLCacheResponse: Response {
    
    public enum Source: Int {
        case Unknown
        case MemoryCache
        case DiskCache
    }
    
    public var source: Source = .Unknown
    
}
