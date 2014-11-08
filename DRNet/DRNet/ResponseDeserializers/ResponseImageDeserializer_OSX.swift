//
//  ResponseImageDeserializer_OSX.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 08/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation
import AppKit

class ResponseImageDeserializer: ResponseDeserializer {
    
    func deserializeResponseData(response: Response) -> (deserializedData: AnyObject?, errors: [NSError]?) {
        if let data = response.data {
            let image = NSImage(data: data)
            if let image = image {
                return (deserializedData: image, errors: nil)
            }
        }
        
        return (deserializedData: nil, errors: [Error()])
    }
    
    class Error: NSError {
        
        class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".ResponseImageDeserializerError" }
        
        init() {
            super.init(
                domain: Error.Domain,
                code: 0,
                userInfo: nil
            )
        }
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
    
}