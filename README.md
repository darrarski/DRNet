DRNet
=====

iOS / OS X networking library written in Swift. Main purpose of this library is to be used as a API client layer in your app.

## Features

* Object oriented architecture
* Written in Swift
* Targeted for both _iOS_ and _OS X_ platforms
* Supports HTTP protocol methods: _GET_, _PUT_, _POST_, _DELETE_, _PATCH_
* Supports setting custom HTTP headers
* Supports request parameters encoded as _Query String_, _URL Form_ or _JSON Body_
* Response validators (ex. data persistance and length, status code)
* Response deserializers (ex. JSON deserializer, image deserializer)
* `NSURLSession` connections with `URLSessionProvider`
* Supports custom caching with `URLCacheProvider` that gives full control of cache and allows to use your app in offline mode
* Extensible architecture allows to implement custom validators, deserializers etc.

## Architecture - brief description

* `Request`
   
   Describes a request with given method, url, headers and parameters
   
* `Response`
   
   Describes response for given `Request`
   
* `Task`
   
   Represents a task that returns `Response` for a `Request` usigng given `Provider`
   
* `Provider`
    
   Can perform a `Task` and return `Response` for given `Request`
   
* `ResponseValidator`
   
   Validates `Response` and generates errors if it doesn't pass validation.
   
   * `ResponseDataValidator`
     
     Checks if `Response` constains valid data with correct length
     
   * `ResponseStatusCodeValidator`
     
     Checks if `Response` has status code in given range
     
* `ResponseDeserializer`
   
   Deserializes `Response` data
   
    * `ResponseJSONDeserializer`
      
     to JSON dictionary
     
    * `ResponseImageDeserializer`
     
     to `UIImage` or `NSImage`, depending on platform
     
* Operation
    
    Performs `Task` and allows to handle errors or success easily, can be chained to implement custom caching policy
    

## Instalation

You can add DRNet library to your project as a git submodule, or just copy it manualy. The library was prepared to be used as a embedded framework in your app. Refer to example apps for hints.

## Usage

Check out included examples:
* [iOS: Loading JSON using GET request with query string parameters](DRNet-Example-iOS/DRNet-Example-iOS/UI/Example1ViewController.swift)
* [iOS: UIImageView extension with remote image loader that supports caching and offline mode](DRNet-Example-iOS/DRNet-Example-iOS/UI/Example2ViewController.swift)

## License

The MIT License (MIT) - check out included [LICENSE](LICENSE) file

## Credits

DRNet library takes some ideas from [Alamofire by Mattt Thompson](https://github.com/Alamofire/Alamofire) with more object oriented architecure and easy extensibility.
