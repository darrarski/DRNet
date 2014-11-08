//
//  ResponseDeserializer.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

protocol ResponseDeserializer {

    func deserializeResponseData(response: Response) -> (deserializedData: AnyObject?, errors: [NSError]?)
    
}