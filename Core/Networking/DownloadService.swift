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

public class DownloadService {
    let alamo: Manager
    public let resumeDataCache: Cache<NSData> // TODO: Make Private once upgrade to swift 2
    public var requestsByKey: [String: Request] = [:] // TODO: Make private once we upgrade to swift 2
    
    public init(identifier: String) {
        let config = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(identifier)
        config.HTTPAdditionalHeaders = Manager.defaultHTTPHeaders
        alamo = Manager(configuration: config)
        resumeDataCache = Cache<NSData>(name: "resumeData-\(identifier)")
    }
    
    public func downloadFile(remoteURL: NSURL, callback: ((NSURL) -> Void)? = nil) {
        let key = keyForURL(remoteURL)
        let request = getRequest(key) ?? makeRequest(remoteURL, key: key)
        request.response { urlRequest, urlResponse, data, error in
            callback?(self.localURLForKey(key))
        }
    }
    
    public func pauseFile(remoteURL: NSURL) {
        let key = keyForURL(remoteURL)
    }
    
    public func removeFile(remoteURL: NSURL) {
        let key = keyForURL(remoteURL)
        getRequest(key)?.cancel()
    }
    
    public func removeAllFiles() {

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
        let originalString = url.absoluteString! as NSString as CFString
        let charactersToLeaveUnescaped = " \\" as NSString as CFString // TODO: Add more characters that are valid in paths but not in URLs
        let legalURLCharactersToBeEscaped = "/:" as NSString as CFString
        let encoding = CFStringBuiltInEncodings.UTF8.rawValue
        let escapedPath = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalString, charactersToLeaveUnescaped, legalURLCharactersToBeEscaped, encoding)
        let key = escapedPath as NSString as String
        if let pathExtension = url.pathExtension where pathExtension != key.pathExtension {
            return "\(key).\(pathExtension)"
        }
        return key
    }
    
    private func localURLForKey(key: String) -> NSURL {
        let directoryURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        return directoryURL.URLByAppendingPathComponent(key)
    }

}
