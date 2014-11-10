//
//  URLCacheProvider.swift
//  DRNet
//
//  Created by Dariusz Rybicki on 05/11/14.
//  Copyright (c) 2014 Darrarski. All rights reserved.
//

import Foundation

public class URLCacheProvider: NSObject, Provider {
    
    public enum MemoryCapacity {
        case Disable
        case Limit(bytes: Int)
        case NoLimit
    }
    
    public enum DiskCapacity {
        case Disable
        case Limit(bytes: Int)
    }
    
    public let memoryCapacity: MemoryCapacity
    public let diskCapacity: DiskCapacity
    public let diskPath: String
    
    public let memoryCache: NSCache = NSCache()
    
    public init(memoryCapacity: MemoryCapacity, diskCapacity: DiskCapacity, diskPath: String) {
        self.memoryCapacity = memoryCapacity
        self.diskCapacity = diskCapacity
        self.diskPath = diskPath
        
        super.init()
        
        switch memoryCapacity {
        case .Disable: ()
        case .NoLimit:
            self.memoryCache.totalCostLimit = 0
        case .Limit(let bytes):
            assert(bytes > 0, "invalid memory capacity, .Limit value should be graten than zero or use .Disable")
            self.memoryCache.totalCostLimit = bytes
        }
        self.memoryCache.evictsObjectsWithDiscardedContent = true
        
        switch diskCapacity {
        case .Disable: ()
        case .Limit(let bytes):
            assert(bytes > 0, "invalid disk capacity, .Limit value should be graten than zero or use .Disable")
            maintainDiskCache()
        }
    }
    
    // MARK: -
    
    public func responseForRequest(request: Request, completion: (response: Response) -> Void) {
        let urlRequest = request.toNSURLRequest()
        var response: URLCacheResponse = {
            var response: URLCacheResponse?
            
            if let cacheKey = self.cacheKeyForRequest(request) {
                if let responseFromMemoryCache = self.responseFromMemoryCache(cacheKey) {
                    response = responseFromMemoryCache
                }
                else if let responseFromDiskCache = self.responseFromDiskCache(cacheKey) {
                    response = responseFromDiskCache
                }
            }
            
            if let response = response {
                return response
            }
            else {
                return URLCacheResponse(URLResponse: nil, data: nil, error: Error(code: .NotFound), forURLRequest: nil)
            }
        }()
        
        completion(response: response)
    }
    
    public func saveResponse(response: Response, forRequest request: Request) {
        if let cacheKey = cacheKeyForRequest(request) {
            let cachedResponse = URLCacheResponse(
                URLResponse: response.URLResponse,
                data: response.data,
                error: response.error,
                forURLRequest: request.toNSURLRequest()
            )
            
            saveResponseInMemoryCache(cachedResponse, cacheKey: cacheKey)
            saveResponseInDiskCache(cachedResponse, cacheKey: cacheKey)
        }
    }
    
    public func removeAllCachedResponses() {
        removeAllResponsesCachedInMemory()
        removeAllResponsesCachedOnDisk()
    }
    
    // MARK: - Memory Caching
    
    private func responseFromMemoryCache(cacheKey: String) -> URLCacheResponse? {
        if !isMemoryCacheEnabled {
            return nil
        }
        
        var response: URLCacheResponse?
        let data = self.memoryCache.objectForKey(cacheKey) as? NSData
        if let data = data {
            response = unarchiveResponse(data)
        }
        
        return response
    }
    
    private func saveResponseInMemoryCache(response: URLCacheResponse, cacheKey: String) {
        if !isMemoryCacheEnabled {
            return
        }
        
        let data = archiveResponse(response)
        memoryCache.setObject(data, forKey: cacheKey, cost: data.length)
    }
    
    private func removeAllResponsesCachedInMemory() {
        self.memoryCache.removeAllObjects()
    }
    
    private func removeResponsesCachedInMemory(cachedKeys: [String]) {
        for key in cachedKeys {
            memoryCache.removeObjectForKey(key)
        }
    }
    
    // MARK: - Disk Caching
    
    private func responseFromDiskCache(cacheKey: String) -> URLCacheResponse? {
        if !isDiskCacheEnabled {
            return nil
        }
        
        var response: URLCacheResponse?
        
        let dataPath = diskCachePath.stringByAppendingPathComponent(cacheKey)
        if let data = NSData(contentsOfFile: dataPath) {
            response = unarchiveResponse(data)
        }
        
        return response
    }
    
    private func saveResponseInDiskCache(response: URLCacheResponse, cacheKey: String) {
        if !isDiskCacheEnabled {
            return
        }
        
        let data = archiveResponse(response)
        let dataPath = diskCachePath.stringByAppendingPathComponent(cacheKey)
        
        createDiskCacheDirectory()
        
        data.writeToFile(dataPath, options: NSDataWritingOptions.DataWritingAtomic, error: nil)
        
        maintainDiskCache()
    }
    
    private func removeAllResponsesCachedOnDisk() {
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(diskCachePath, error: nil)
    }
    
    private func removeResponsesCachedOnDisk(cacheKeys: [String]) {
        let fileManager = NSFileManager.defaultManager()
        for key in cacheKeys {
            let path = diskCachePath.stringByAppendingPathComponent(key)
            fileManager.removeItemAtPath(path, error: nil)
        }
    }
    
    private lazy var diskCachePath: String = {
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let path = (paths.first! as String).stringByAppendingPathComponent(self.diskPath)
        return path
    }()
    
    private func createDiskCacheDirectory() {
        let fileManager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        let fileExist = fileManager.fileExistsAtPath(diskCachePath, isDirectory: &isDirectory)
        if !fileExist || !isDirectory {
            fileManager.createDirectoryAtPath(diskCachePath, withIntermediateDirectories: true, attributes: nil, error: nil)
        }
    }
    
    private func maintainDiskCache() {
        if !isDiskCacheEnabled {
            return
        }
        
        let fileManager = NSFileManager.defaultManager()
        
        let fileURLs = fileManager.contentsOfDirectoryAtURL(
            NSURL(fileURLWithPath: diskCachePath, isDirectory: true)!,
            includingPropertiesForKeys: [
                NSFileSize,
                NSFileModificationDate
            ],
            options: NSDirectoryEnumerationOptions.allZeros,
            error: nil
        ) as? [NSURL]
        
        if let fileURLs = fileURLs {
            
            struct File {
                let path: String
                let modificationDate: NSDate
                let size: Int
                
                func removeUsingFileManager(fileManager: NSFileManager) {
                    fileManager.removeItemAtPath(path, error: nil)
                }
            }
            
            var totalSize: Int = 0
            
            var files: [File] = fileURLs.map({
                let path = $0.path!
                let info = fileManager.attributesOfItemAtPath(path, error: nil)!
                let modificationDate = info[NSFileModificationDate] as NSDate
                let size = info[NSFileSize] as Int
                totalSize += size
                
                return File(path: path, modificationDate: modificationDate, size: size)
            })
            
            files.sort({ (first, second) -> Bool in
                return (first.modificationDate.compare(second.modificationDate) == .OrderedDescending)
            })
            
            let diskCapacityInBytes: Int = {
                switch self.diskCapacity {
                case .Disable: return 0
                case .Limit(let bytes): return bytes
                }
            }()
            
            while totalSize > diskCapacityInBytes {
                if let oldestFile = files.last {
                    oldestFile.removeUsingFileManager(fileManager)
                    totalSize -= oldestFile.size
                    files.removeLast()
                }
                else {
                    break
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var isMemoryCacheEnabled: Bool {
        switch memoryCapacity {
        case .Disable: return false
        default: return true
        }
    }
    
    private var isDiskCacheEnabled: Bool {
        switch diskCapacity {
        case .Disable: return false
        default: return true
        }
    }
    
    private func cacheKeyForRequest(request: Request) -> String? {
        let urlRequest = request.toNSURLRequest()
        let data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(urlRequest)
        archiver.finishEncoding()
        
        if data.length > 0 {
            return URLCacheProvider.MD5(data)
        }
        
        return nil
    }
    
    private func archiveResponse(response: URLCacheResponse) -> NSData {
        var data = NSMutableData()
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(response)
        archiver.finishEncoding()
        
        return data.copy() as NSData
    }
    
    private func unarchiveResponse(data: NSData) -> URLCacheResponse? {
        let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
        let response = unarchiver.decodeObject() as? URLCacheResponse
        unarchiver.finishDecoding()
        
        return response
    }
    
    // MARK: - MD5
    
    private class func MD5(data: NSData) -> String {
        let result = NSMutableData(length: Int(CC_MD5_DIGEST_LENGTH))!
        let resultBytes = UnsafeMutablePointer<CUnsignedChar>(result.mutableBytes)
        CC_MD5(data.bytes, CC_LONG(data.length), resultBytes)
        
        let a = UnsafeBufferPointer<CUnsignedChar>(start: resultBytes, count: result.length)
        let hash = NSMutableString()
        
        for i in a {
            hash.appendFormat("%02x", i)
        }
        
        return hash
    }
    
    private class func MD5(string: String) -> String {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        return MD5(data)
    }
    
    // MARK: - Error
    
    public class Error: NSError {
        
        class var Domain: String { return NSBundle(forClass: classForCoder()).bundleIdentifier! + ".URLCacheProviderError" }
        
        enum Code: Int {
            case NotFound = 1
        }
        
        init(code: Code) {
            super.init(
                domain: Error.Domain,
                code: code.rawValue,
                userInfo: nil
            )
        }
        
        public required init(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }
        
    }
    
}