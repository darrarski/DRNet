//
//  ResponseDataValidator.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class ResponseDataValidator: ResponseValidator {
    
    public init() {}
    
    // MARK: - ResponseValidator protocol
    
    public func validateResponse(response: Response, forRequest: Request) -> [NSError]? {
        if let data = response.data {
            if let expectedContentLength = response.URLResponse?.expectedContentLength {
                if (expectedContentLength > -1) {
                    if Int64(data.length) < expectedContentLength {
                        return [Error(code: .InvalidDataLength)]
                    }
                }
            }
        }
        else {
            return [Error(code: .EmptyData)]
        }
        
        return nil
    }
    
    // MARK: - Error
    
    public class Error: NSError {
        
        public class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".ResponseDataValidatorError" }
        
        public enum Code: Int {
            case EmptyData = 1
            case InvalidDataLength = 2
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
            let codeString: String = {
                switch Code(rawValue: self.code) {
                case .Some(.EmptyData):
                    return "empty data"
                case .Some(.InvalidDataLength):
                    return "invalid data length"
                case .None:
                    return "unhandled error"
                }
            }()
            return "Expected valid response data, but got \(codeString)"
        }
        
    }
    
}