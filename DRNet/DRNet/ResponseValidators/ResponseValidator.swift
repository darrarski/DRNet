//
//  ResponseValidator.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

protocol ResponseValidator {
    
    func validateResponse(response: Response, forRequest: Request) -> [NSError]?
    
}