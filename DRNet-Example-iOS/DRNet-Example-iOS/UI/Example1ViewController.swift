//
//  Example1ViewController.swift
//  DRNet-Example-iOS
//
//  Created by Dariusz Rybicki on 09/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import UIKit
import DRNet

class Example1ViewController: TextViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Example 1"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        runExample()
    }
    
    func runExample() {
        
        textView.text = "Loading JSON using GET request with query string parameters.\n\n"
        
        let request = DRNet.Request(
            method: .GET,
            url: NSURL(string: "http://api.openweathermap.org/data/2.5/weather")!,
            headers: nil,
            parameters: DRNet.RequestQueryStringParameters(
                [
                    "q": "Warsaw,pl"
                ]
            )
        )
        
        let operation = DRNet.Operation(
            validators: [
                DRNet.ResponseDataValidator(),
                DRNet.ResponseStatusCodeValidator(200..<299)
            ],
            dataDeserializer: DRNet.ResponseJSONDeserializer(),
            handlerClosure: { [weak self] (operation, request, task, response, deserializedData, errors) -> Void in
                var output: String = ""
                
                if errors?.count > 0 {
                    output += "Error(s) occured:\n\n"
                    
                    output += "\n\n---\n\n".join(
                        errors!.map({ (error) in
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
                }
                else {
                    output += "Completed without errors.\n\n"
                    
                    var placeName: String = "N/A"
                    var countryCode: String = "N/A"
                    var currentTemp: Float?
                    var currentPressure: Float?
                    var descriptions: [String] = []
                    var jsonString: String?
                    
                    if let jsonDict = deserializedData as? [String: AnyObject] {
                        if let name = jsonDict["name"] as? String {
                            placeName = name
                        }
                        
                        if let sys = jsonDict["sys"] as? [String: AnyObject] {
                            if let country = sys["country"] as? String {
                                countryCode = country
                            }
                        }
                        
                        if let main = jsonDict["main"] as? [String: AnyObject] {
                            if let temp = main["temp"] as? Float {
                                currentTemp = temp.kelvinToCelsius()
                            }
                            
                            if let pressure = main["pressure"] as? Float {
                                currentPressure = pressure
                            }
                        }
                        
                        if let weathers = jsonDict["weather"] as? [[String: AnyObject]] {
                            for weather in weathers {
                                if let description = weather["description"] as? String {
                                    descriptions.append(description)
                                }
                            }
                        }
                        
                        if let jsonData = NSJSONSerialization.dataWithJSONObject(jsonDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil) {
                            if let string: String = NSString(data: jsonData, encoding: NSUTF8StringEncoding) {
                                jsonString = string
                            }
                        }
                    }
                    
                    output += "Current weather in \(placeName), \(countryCode):\n"
                    
                    if let currentTemp = currentTemp {
                        output += "Temperature: \(currentTemp) C\n"
                    }
                    
                    if let currentPressure = currentPressure {
                        output += "Pressure: \(currentPressure) hPa\n"
                    }
                    
                    if descriptions.count > 0 {
                        output += "Description: " + ", ".join(descriptions) + "\n"
                    }
                    
                    if let jsonString = jsonString {
                        output += "\nJSON:\n\(jsonString)\n"
                    }
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if let sself = self {
                        sself.textView.text = sself.textView.text + output
                    }
                })
            }
        )
        
        let provider = DRNet.URLSessionProvider(session: NSURLSession.sharedSession())
        
        let task = DRNet.Task(provider: provider)
        
        operation.perfromRequest(
            request,
            withTask: task
        )
        
    }
    
}

extension Float {
    
    func kelvinToCelsius() -> Float {
        return self - 273.15
    }
    
}
