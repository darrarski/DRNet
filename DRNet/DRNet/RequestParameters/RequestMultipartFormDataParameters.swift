//
//  RequestMultipartFormDataParameters.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 17/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class RequestMultipartFormDataParameters: RequestParameters {
    
    let parameters: [RequestMultipartFormDataParameter]
    
    init(parameters: [RequestMultipartFormDataParameter]) {
        self.parameters = parameters
    }
    
    // MARK: - RequestParameters protocol
    
    public func setParametersInRequest(request: NSURLRequest) -> NSURLRequest {
        var mutableURLRequest: NSMutableURLRequest! = request.mutableCopy() as NSMutableURLRequest
        setParametersInRequest(mutableURLRequest)
        
        return request.copy() as NSURLRequest
    }
    
    public func setParametersInRequest(request: NSMutableURLRequest) {
        let boundary = boundaryString()
        initializeMultipartRequest(request, boundary: boundary)
        var body = NSMutableData()
        
        for parameter in parameters {
            if let stringParameter = parameter as? StringParameter {
                appendStringToMultipartData(body, boundary: boundary, name: stringParameter.name, value: stringParameter.value)
            }
            else if let fileParameter = parameter as? FileParameter {
                appendFileToMultipartData(body, boundary: boundary, name: fileParameter.name, filename: fileParameter.filename, contentType: fileParameter.contentType, fileData: fileParameter.data)
            }
        }
        
        finalizeMultipartData(body, boundary: boundary)
        request.HTTPBody = body
    }
    
    // MARK: - Multipart body generation
    
    private func boundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    
    private func initializeMultipartRequest(request: NSMutableURLRequest, boundary: String) {
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    }
    
    private func appendStringToMultipartData(data: NSMutableData, boundary: String, name: String, value: String) {
        data.appendDataString("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"\r\n\r\n\(value)\r\n")
    }
    
    private func appendFileToMultipartData(data: NSMutableData, boundary: String, name: String, filename: String, contentType: String, fileData: NSData) {
        data.appendDataString("--\(boundary)\r\nContent-Disposition: form-data; name=\"\(name)\"; filename=\"\(filename)\"\r\nContent-Type: \(contentType)\r\n\r\n")
        data.appendData(fileData)
        data.appendDataString("\r\n")
    }
    
    private func finalizeMultipartData(data: NSMutableData, boundary: String) {
        data.appendDataString("--\(boundary)--\r\n")
    }
    
    // MARK: - Parameter types
    
    struct FileParameter: RequestMultipartFormDataParameter {
        let name: String
        let filename: String
        let contentType: String
        let data: NSData
    }
    
    struct StringParameter: RequestMultipartFormDataParameter {
        let name: String
        let value: String
    }
    
}

public protocol RequestMultipartFormDataParameter {
    
    var name: String { get }
    
}

extension NSMutableData {
    
    private func appendDataString(string: String, usingEncoding: NSStringEncoding = NSUTF8StringEncoding) {
        appendData(string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!)
    }
    
}

