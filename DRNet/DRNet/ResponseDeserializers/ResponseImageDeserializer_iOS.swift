//
//  ResponseImageDeserializer.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 04/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation
import UIKit

public class ResponseImageDeserializer: ResponseDeserializer {
    
    public func deserializeResponseData(response: Response) -> (deserializedData: AnyObject?, errors: [NSError]?) {
        if let data = response.data {
            let image = UIImage(data: data)
            if let image = image {
                return (deserializedData: image, errors: nil)
            }
        }
        
        return (deserializedData: nil, errors: [Error()])
    }
    
    public class Error: NSError {
        
        public class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".ResponseImageDeserializerError" }
        
        init() {
            super.init(
                domain: Error.Domain,
                code: 0,
                userInfo: nil
            )
        }
        
        public required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
    
}