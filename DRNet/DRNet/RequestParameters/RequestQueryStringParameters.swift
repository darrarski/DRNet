//
//  RequestQueryStringParameters.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 21/10/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class RequestQueryStringParameters: RequestParameters {
    
    public let parameters: [String: AnyObject]
    
    public init(_ parameters: [String: AnyObject]) {
        self.parameters = parameters
    }
    
    // MARK: - RequestParameters protocol
    
    public func setParametersInRequest(request: NSURLRequest) -> NSURLRequest {
        var mutableURLRequest: NSMutableURLRequest! = request.mutableCopy() as NSMutableURLRequest
        setParametersInRequest(mutableURLRequest)
        
        return request.copy() as NSURLRequest
    }
    
    public func setParametersInRequest(request: NSMutableURLRequest) {
        if let URLComponents = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false) {
            URLComponents.percentEncodedQuery = (URLComponents.query != nil ? URLComponents.query! + "&" : "") + query(parameters)
            request.URL = URLComponents.URL
        }
        else {
            assertionFailure("Unable to set Query String parameters in request")
        }
    }
    
    // MARK: -
    
    func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in sorted(Array(parameters.keys), <) {
            let value: AnyObject! = parameters[key]
            components += queryComponents(key, value)
        }
        
        return join("&", components.map{"\($0)=\($1)"} as [String])
    }
    
    func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        }
        else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        }
        else {
            components.extend([(escape(key), escape("\(value)"))])
        }
        
        return components
    }
    
    func escape(string: String) -> String {
        let allowedCharacters =  NSCharacterSet(charactersInString:" =\"#%/<>?@\\^`{}[]|&").invertedSet
        return string.stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacters) ?? string
    }
    
}