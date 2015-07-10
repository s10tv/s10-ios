//
//  DownloadService.swift
//  S10
//
//  Created by Tony Xiao on 7/8/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import BrightFutures
import Alamofire
import Haneke
import Result

public enum NSURLSessionType {
    case Default, Ephemeral, Background
    func sessionConfig(identifier: String) -> NSURLSessionConfiguration {
        switch self {
        case .Default: return NSURLSessionConfiguration.defaultSessionConfiguration()
        case .Ephemeral: return NSURLSessionConfiguration.ephemeralSessionConfiguration()
        case .Background: return NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        }
    }
}

public class DownloadService {
    public struct Errors {
        static let NotFound = NSError(domain: "DownloadService", code: 1, userInfo: nil)
    }
    
    let identifier: String
    let alamo: Manager
    let queue = Queue()
    public let resumeDataCache: Cache<NSData> // TODO: Make Private once upgrade to swift 2
    public var requestsByKey: [String: Request] = [:] // TODO: Make private once we upgrade to swift 2
    
    public var baseDir: NSURL {
        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        return directoryURL.URLByAppendingPathComponent(escapeString(identifier))
    }
    
    public init(identifier: String, sessionType: NSURLSessionType = .Default) {
        self.identifier = identifier
        alamo = Manager(configuration: {
            let config = sessionType.sessionConfig(identifier)
            config.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
            return config
        }())
        resumeDataCache = Cache<NSData>(name: "resumeData-\(identifier)")
        NSFileManager.defaultManager().createDirectoryAtURL(baseDir,
            withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    public func downloadFile(remoteURL: NSURL) -> Future<NSURL, NSError> {
        let key = keyForURL(remoteURL)
        return perform {
            getRequest(key).map { future($0) } ?? makeRequest(remoteURL, key: key)
        }.mapError { _ in
            NSError() // TODO: Big hack, revise flatMap to promoteError?
        }.flatMap {
            $0.responseData()
        }.map { _ -> NSURL in
            self.resumeDataCache.remove(key: key)
            return self.localURLForKey(key)
        }
    }
    
    public func pauseDownloadFile(remoteURL: NSURL) -> Future<(), NoError> {
        return future(context: queue.context) {
            let key = self.keyForURL(remoteURL)
            if let request = self.getRequest(key) {
                request.cancel()
                request.response { _, _, data, _ in
                    self.resumeDataCache.set(value: data as! NSData, key: key)
                }
            }
            return Result(value: ())
        }
    }
    
    public func fetchFile(remoteURL: NSURL) -> Future<NSURL, NSError> {
        let localURL = localURLForKey(keyForURL(remoteURL))
        return future(context: queue.context) {
            if let path = localURL.path where NSFileManager().fileExistsAtPath(path) {
                return Result(value: localURL)
            }
            return Result(error: Errors.NotFound)
        }
    }
    
    public func removeFile(remoteURL: NSURL) -> Future<(), NoError> {
        let key = keyForURL(remoteURL)
        getRequest(key)?.cancel()
        let localURL = localURLForKey(key)
        return future(context: queue.context) {
            NSFileManager().removeItemAtURL(localURL, error: nil)
            return Result(value: ())
        }
    }
    
    public func removeAllFiles() -> Future<(), NoError> {
        return future(context: queue.context) {
            self.resumeDataCache.removeAll()
            let fm = NSFileManager()
            fm.removeItemAtURL(self.baseDir, error: nil)
            fm.createDirectoryAtURL(self.baseDir, withIntermediateDirectories: true, attributes: nil, error: nil)
            return Result(value: ())
        }
    }
    
    private func getRequest(key: String) -> Request? {
        return requestsByKey[key]
    }
    
    private func makeRequest(remoteURL: NSURL, key: String) -> Future<Request, NoError> {
        let dest: (NSURL, NSURLResponse) -> NSURL = { [weak self] tempURL, response in
            return self?.localURLForKey(key) ?? tempURL
        }
        return perform {
            resumeDataCache.fetch(key)
        }.map {
            self.alamo.download($0, destination: dest)
        }.recover { _ in
            self.alamo.download(.GET, remoteURL, destination: dest)
        }.map {
            $0.validate()
        }.onSuccess {
            self.requestsByKey[key] = $0
        }
    }
    
    private func keyForURL(url: NSURL) -> String {
        let key = escapeString(url.absoluteString!)
        if let pathExtension = url.pathExtension where pathExtension != key.pathExtension {
            return "\(key).\(pathExtension)"
        }
        return key
    }
    
    private func localURLForKey(key: String) -> NSURL {
        return baseDir.URLByAppendingPathComponent(key)
    }
    
    private func escapeString(str: String) -> String {
        let originalString = str as NSString as CFString
        let charactersToLeaveUnescaped = " \\" as NSString as CFString // TODO: Add more characters that are valid in paths but not in URLs
        let legalURLCharactersToBeEscaped = "/:" as NSString as CFString
        let encoding = CFStringBuiltInEncodings.UTF8.rawValue
        let escapedPath = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalString, charactersToLeaveUnescaped, legalURLCharactersToBeEscaped, encoding)
        return escapedPath as NSString as String
    }
}
