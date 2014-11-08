//
//  URLSessionProvider.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 05/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class URLSessionProvider: Provider {
    
    public let session: NSURLSession
    
    public init(session: NSURLSession) {
        self.session = session
    }
    
    public func responseForRequest(request: Request, completion: (response: Response) -> Void) {
        let URLRequest = request.toNSURLRequest()
        let task = NSURLSession.sharedSession().dataTaskWithRequest(URLRequest) { (data, URLResponse, error) -> Void in
            let response = Response(URLResponse: URLResponse, data: data, error: error, forURLRequest: URLRequest)
            completion(response: response)
        }
        task.resume()
    }
    
}