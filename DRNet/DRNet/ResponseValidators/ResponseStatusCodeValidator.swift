//
//  ResponseStatusCodeValidator.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class ResponseStatusCodeValidator: ResponseValidator {
    
    public let expectedStatusCodeRange: Range<Int>
    
    public init(_ expectedStatusCodeRange: Range<Int>) {
        self.expectedStatusCodeRange = expectedStatusCodeRange
    }
    
    // MARK: - ResponseValidator protocol
    
    public func validateResponse(response: Response, forRequest: Request) -> [NSError]? {
        var errors: [NSError] = []
        
        if let HTTPURLResponse = response.URLResponse as? NSHTTPURLResponse {
            if !contains(expectedStatusCodeRange, HTTPURLResponse.statusCode) {
                errors.append(Error(expectedStatusCodeRange: expectedStatusCodeRange, statusCode: HTTPURLResponse.statusCode))
            }
        }
        else {
            errors.append(Error(expectedStatusCodeRange: expectedStatusCodeRange, statusCode: nil))
        }
        
        return errors.count > 0 ? errors : nil
    }
    
    // MARK: - Error
    
    public class Error: NSError {
        
        public class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".ResponseStatusCodeValidatorError" }
        
        init(expectedStatusCodeRange: Range<Int>, statusCode: Int?) {
            var userInfo: [String: Int] = [
                "expectedStatusCodeRangeStart": expectedStatusCodeRange.startIndex,
                "expectedStatusCodeRangeEnd": expectedStatusCodeRange.endIndex
            ]
            userInfo["statusCode"] = statusCode
            
            super.init(
                domain: Error.Domain,
                code: {
                    if let statusCode = statusCode {
                        return statusCode
                    }
                    
                    return 0
                }(),
                userInfo: userInfo
            )
        }
        
        public required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
        // MARK: Properties
        
        public var expectedStatusCodeRange: Range<Int> {
            return Range<Int>(
                start: userInfo!["expectedStatusCodeRangeStart"] as Int,
                end: userInfo!["expectedStatusCodeRangeEnd"] as Int
            )
        }
        
        public var statusCode: Int? {
            return userInfo?["statusCode"] as? Int
        }
        
    }
    
}