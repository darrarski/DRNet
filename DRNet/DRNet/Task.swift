//
//  Task.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class Task {
    
    public let provider: Provider
    
    public init(provider: Provider) {
        self.provider = provider
    }
    
    public func performRequest(request: Request, completion: (response: Response) -> Void) {
        provider.responseForRequest(request, completion: { (response) -> Void in
            completion(response: response)
        })
    }
    
}