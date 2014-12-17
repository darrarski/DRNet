//
//  Operation.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 02/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class Operation {
    
    public typealias OnErrorClosure = (response: Response, deserializedData: AnyObject?, errors: [NSError], shouldHandle: UnsafeMutablePointer<Bool>) -> Void
    public typealias OnSuccessClosure = (response: Response, deserializedData: AnyObject?, shouldHandle: UnsafeMutablePointer<Bool>) -> Void
    public typealias HandlerClosure = (operation: Operation, request: Request, task: Task, response: Response, deserializedData: AnyObject?, errors: [NSError]?) -> Void
    public typealias OnCompleteClosure = (response: Response, deserializedData: AnyObject?, errors: [NSError]?) -> Void
    
    public let validators: [ResponseValidator] = []
    public let dataDeserializer: ResponseDeserializer? = nil
    public let handlerClosure: HandlerClosure?

    public var aborted: Bool {
        return _aborted
    }
    private var _aborted = false
    
    public init(validators: [ResponseValidator]?, dataDeserializer: ResponseDeserializer?, handlerClosure: HandlerClosure?) {
        if let validators = validators {
            self.validators = validators
        }
        self.dataDeserializer = dataDeserializer
        self.handlerClosure = handlerClosure
    }
    
    public func perfromRequest(request: Request, usingProvider provider: Provider, onError: OnErrorClosure? = nil, onSuccess: OnSuccessClosure? = nil, onComplete: OnCompleteClosure? = nil) {
        let task = Task(provider: provider)
        perfromRequest(request, withTask: task, onError: onError, onSuccess: onSuccess, onComplete: onComplete)
    }
    
    public func perfromRequest(request: Request, withTask task: Task, onError: OnErrorClosure? = nil, onSuccess: OnSuccessClosure? = nil, onComplete: OnCompleteClosure? = nil) {
            
        task.performRequest(request, completion: { [weak self] (response) -> Void in
            if let sself = self {
                if sself.aborted { return }

                var deserializedData: AnyObject?
                var errorsSet = NSMutableOrderedSet()
                
                if let error = response.error {
                    errorsSet.addObject(error)
                }
                
                for validator: ResponseValidator in sself.validators {
                    if let errors = validator.validateResponse(response, forRequest: request) {
                        errorsSet.addObjectsFromArray(errors)
                    }
                }
                
                if let deserializer = sself.dataDeserializer {
                    let (data: AnyObject?, errors) = deserializer.deserializeResponseData(response)
                    deserializedData = data
                    if let errors = errors {
                        errorsSet.addObjectsFromArray(errors)
                    }
                }

                if sself.aborted { return }
                
                var shouldHandle = true
                
                if errorsSet.count > 0 {
                    if let onError = onError {
                        onError(
                            response: response,
                            deserializedData: deserializedData,
                            errors: errorsSet.array as [NSError],
                            shouldHandle: &shouldHandle
                        )
                    }
                }
                else {
                    if let onSuccess = onSuccess {
                        onSuccess(
                            response: response,
                            deserializedData: deserializedData,
                            shouldHandle: &shouldHandle
                        )
                    }
                }

                if sself.aborted { return }
                
                let errors = errorsSet.count > 0 ? errorsSet.array as? [NSError] : nil
                
                if shouldHandle {
                    sself.handlerClosure?(
                        operation: sself,
                        request: request,
                        task: task,
                        response: response,
                        deserializedData: deserializedData,
                        errors: errors
                    )
                }
                
                if let onComplete = onComplete {
                    onComplete(
                        response: response,
                        deserializedData: deserializedData,
                        errors: errors
                    )
                }
            }
        })
    }

    public func abort() {
        _aborted = true
    }
    
}