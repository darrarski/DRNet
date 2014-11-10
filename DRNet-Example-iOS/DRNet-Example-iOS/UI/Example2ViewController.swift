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
        initMenu()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        runExample()
    }
    
    func runExample() {
        
        // remove all cached responses in iOS shared URL cache, to assure DRNet caching works
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        
        exampleInProgress = true
        
        label.text = "UIImageView extension with remote image loader that supports caching and offline mode."
        
        imageView.loadImageFromURL(
            NSURL(string: "http://placekitten.com/g/1024/512")!,
            onLoadFromCacheSuccess: { [weak self] (source: DRNet.URLCacheResponse.Source) -> Void in
                let sourceString: String = {
                    switch source {
                    case .Unknown:
                        return "unknown"
                    case .MemoryCache:
                        return "memory"
                    case .DiskCache:
                        return "disk"
                    }
                }()
                self?.logText("Successfully loaded from \(sourceString) cache.")
                return
            },
            onLoadFromCacheFailure: { [weak self] (errors) -> Void in
                self?.logText("Error(s) occured when loading from cache:")
                self?.logErrors(errors)
            },
            onLoadFromNetworkSuccess: { [weak self] () -> Void in
                self?.logText("Successfully loaded from network.")
                return
            },
            onLoadFromNetworkFailure: { [weak self] (errors) -> Void in
                self?.logText("Error(s) occured when loading from network:")    
                self?.logErrors(errors)
            },
            onComplete: { [weak self] () -> Void in
                self?.logText("Done.\n\nTap on image to open options menu.")
                self?.exampleInProgress = false
            }
        )
    }
    
    // MARK: - Menu
    
    private var imageViewTapGestureRecognizer: UITapGestureRecognizer?
    
    private func initMenu() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: "showMenu")
        imageView.addGestureRecognizer(gestureRecognizer)
        imageView.userInteractionEnabled = true
    }
    
    func showMenu() {
        if exampleInProgress {
            return
        }
        
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(
            UIAlertAction(
                title: "Reload image",
                style: UIAlertActionStyle.Default,
                handler: { [weak self] (action) -> Void in
                    self?.runExample()
                    return
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Clear cache",
                style: UIAlertActionStyle.Destructive,
                handler: { (action) -> Void in
                    ImageViewCacheProvider.removeAllCachedResponses()
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertActionStyle.Cancel,
                handler: nil
            )
        )
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    private var exampleInProgress = false
    
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
        onLoadFromCacheSuccess: (source: DRNet.URLCacheResponse.Source) -> Void,
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
                onLoadFromCacheSuccess(source: (response as DRNet.URLCacheResponse).source)
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