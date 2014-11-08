//
//  Provider.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 05/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

protocol Provider {
    
    func responseForRequest(request: Request, completion: (response: Response) -> Void)
    
}