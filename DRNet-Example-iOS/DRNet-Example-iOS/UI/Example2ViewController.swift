//
//  Example2ViewController.swift
//  DRNet-Example-iOS
//
//  Created by Dariusz Rybicki on 10/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import UIKit
import DRNet

class Example2ViewController: ImageTextViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Example 2"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        runExample()
    }
    
    func runExample() {
        
        label.text = "UIImageView extension with remote image loader that supports caching and offline mode."
        
        imageView.loadImageFromURL(
            NSURL(string: "http://placekitten.com/g/400/200")!,
            onLoadFromCacheSuccess: { [weak self] () -> Void in
                self?.logText("Successfully loaded from cache")
                return
            },
            onLoadFromCacheFailure: { [weak self] (errors) -> Void in
                self?.logText("Error(s) occured when loading from cache:")
                self?.logErrors(errors)
            },
            onLoadFromNetworkSuccess: { [weak self] () -> Void in
                self?.logText("Successfully loaded from network")
                return
            },
            onLoadFromNetworkFailure: { [weak self] (errors) -> Void in
                self?.logText("Error(s) occured when loading from network:")    
                self?.logErrors(errors)
            },
            onComplete: { [weak self] () -> Void in
                self?.logText("Done")
                return
            }
        )
    }
    
    private func logErrors(errors: [NSError]) {
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            var output: String = "\n\n---\n\n".join(
                errors.map({ (error) in
                    var message: String = error.localizedDescription
                    
                    if let failureReason = error.localizedFailureReason {
                        message += ", " + failureReason
                    }
                    
                    if countElements(error.debugDescription) > 0 {
                        message += ", " + error.debugDescription
                    }
                    
                    return message
                })
            )
            
            if let sself = self {
                if let currentText = sself.label.text {
                    sself.label.text = currentText + "\n\n" + output
                }
                else {
                    sself.label.text = output
                }
            }
        })
    }
    
    private func logText(text: String) {
        dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
            if let sself = self {
                if let currentText = sself.label.text {
                    sself.label.text = currentText + "\n\n" + text
                }
                else {
                    sself.label.text = text
                }
            }
        })
    }
    
}

private let ImageViewNetworkProvider = DRNet.URLSessionProvider(session: NSURLSession.sharedSession())
private let ImageViewCacheProvider = DRNet.URLCacheProvider(
    memoryCapacity: .Limit(bytes: 10 * 1024 * 1024),
    diskCapacity: .Limit(bytes: 10 * 1024 * 1024),
    diskPath: "ImageViewCache"
)

extension UIImageView {
    
    func loadImageFromURL(url: NSURL,
        onLoadFromCacheSuccess: () -> Void,
        onLoadFromCacheFailure: (errors: [NSError]) -> Void,
        onLoadFromNetworkSuccess: () -> Void,
        onLoadFromNetworkFailure: (errors: [NSError]) -> Void,
        onComplete: () -> Void) {
        
        let request = DRNet.Request(
            method: .GET,
            url: url,
            headers: DRNet.RequestStandardHeaders(
                [
                    "Accept": "image/*"
                ]
            ),
            parameters: nil
        )
        
        let operation = DRNet.Operation(
            validators: [
                DRNet.ResponseDataValidator(),
                DRNet.ResponseStatusCodeValidator(200..<299)
            ],
            dataDeserializer: DRNet.ResponseImageDeserializer(),
            handlerClosure: { [weak self] (operation, request, task, response, deserializedData, errors) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self?.image = deserializedData as? UIImage
                    return
                })
            }
        )
        
        var loadedFromCache = false
        
        operation.perfromRequest(request,
            usingProvider: ImageViewCacheProvider,
            onError: { (response, deserializedData, errors, shouldHandle) -> Void in
                shouldHandle.memory = false
                onLoadFromCacheFailure(errors: errors)
            },
            onSuccess: { (response, deserializedData, shouldHandle) -> Void in
                loadedFromCache = true
                onLoadFromCacheSuccess()
            },
            onComplete: { (response, deserializedData, errors) -> Void in
                operation.perfromRequest(request,
                    usingProvider: ImageViewNetworkProvider,
                    onError: { (response, deserializedData, errors, shouldHandle) -> Void in
                        shouldHandle.memory = !loadedFromCache
                        onLoadFromNetworkFailure(errors: errors)
                    },
                    onSuccess: { (response, deserializedData, shouldHandle) -> Void in
                        ImageViewCacheProvider.saveResponse(response, forRequest: request)
                        onLoadFromNetworkSuccess()
                    },
                    onComplete: { (response, deserializedData, errors) -> Void in
                        onComplete()
                    }
                )
            }
        )
        
    }
    
}