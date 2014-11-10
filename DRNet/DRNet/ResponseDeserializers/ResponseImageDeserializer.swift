//
//  ResponseImageDeserializer.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 04/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
#elseif os(OS_X)
    import Cocoa
#endif

public class ResponseImageDeserializer: ResponseDeserializer {
    
    public init() {}
    
    public func deserializeResponseData(response: Response) -> (deserializedData: AnyObject?, errors: [NSError]?) {
        if let data = response.data {
            #if os(iOS)
                let image = UIImage(data: data)
                if let image = image {
                    return (deserializedData: image, errors: nil)
                }
            #elseif os(OS_X)
                let image = NSImage(data: data)
                if let image = image {
                    return (deserializedData: image, errors: nil)
                }
            #endif
            
            return (deserializedData: nil, errors: [Error(code: .DeserializationError)])
        }
        
        return (deserializedData: nil, errors: [Error(code: .EmptyData)])
    }
    
    public class Error: NSError {
        
        public class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".ResponseImageDeserializerError" }
        
        public enum Code: Int {
            case EmptyData = 1
            case DeserializationError = 2
        }
        
        init(code: Code) {
            super.init(
                domain: Error.Domain,
                code: code.rawValue,
                userInfo: nil
            )
        }
        
        public required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        // MARK: Description
        
        public override var description: String {
            switch Code(rawValue: self.code) {
            case .Some(.EmptyData):
                return "Unable to deserialize image from empty response data"
            case .Some(.DeserializationError):
                return "Unable to deserialize image from response data"
            case .None:
                return "ResponseImageDeserializer unhandled error"
            }
        }
        
    }
    
}