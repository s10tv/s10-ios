//
//  DownloadService.swift
//  S10
//
//  Created by Tony Xiao on 7/8/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire
import Haneke


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
    let identifier: String
    let alamo: Manager
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
    
    public func downloadFile(remoteURL: NSURL) -> SignalProducer<NSURL, NSError> {
        let key = keyForURL(remoteURL)
        let request = getRequest(key) ?? makeRequest(remoteURL, key: key)
        let (producer, sink) = SignalProducer<NSURL, NSError>.buffer(1)
        request.response { urlRequest, urlResponse, data, error in
            if let error = error {
                sendError(sink, error)
            } else {
                sendNext(sink, self.localURLForKey(key))
                sendCompleted(sink)
            }
        }
        return producer
    }
    
    public func pauseFile(remoteURL: NSURL) {
        let key = keyForURL(remoteURL)
    }
    
    public func removeFile(remoteURL: NSURL) {
        let key = keyForURL(remoteURL)
        getRequest(key)?.cancel()
    }
    
    public func removeAllFiles() {
        let fm = NSFileManager()
        fm.removeItemAtURL(baseDir, error: nil)
        fm.createDirectoryAtURL(baseDir, withIntermediateDirectories: true, attributes: nil, error: nil)
    }
    
    private func getRequest(key: String) -> Request? {
        return requestsByKey[key]
    }
    
    private func makeRequest(remoteURL: NSURL, key: String) -> Request {
        let dest = Request.suggestedDownloadDestination(directory: .CachesDirectory)
        let request = alamo.download(.GET, remoteURL) { [weak self] tempURL, response in
            return self?.localURLForKey(key) ?? tempURL
        }.validate()
        requestsByKey[key] = request
        return request
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
