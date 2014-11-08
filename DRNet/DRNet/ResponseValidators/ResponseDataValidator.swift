//
//  ResponseDataValidator.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

class ResponseDataValidator: ResponseValidator {
    
    init() {}
    
    // MARK: - ResponseValidator protocol
    
    func validateResponse(response: Response, forRequest: Request) -> [NSError]? {
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
    
    class Error: NSError {
        
        class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".ResponseDataValidatorError" }
        
        enum Code: Int {
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
        
        required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
    
}