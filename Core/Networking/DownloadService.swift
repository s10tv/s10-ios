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
import Async

public let DownloadSuccessNotification = "DownloadSuccessNotification"

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
    public var futuresByKey: [String: Future<NSURL, NSError>] = [:]
    
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
        Log.verbose("downloadFile called \(remoteURL)")
        if let localURL = fetchFile(remoteURL) {
            return Future.succeeded(localURL)
        }
        let key = keyForURL(remoteURL)
        if futuresByKey[key] == nil {
            futuresByKey[key] = perform {
                getRequest(key).map { future($0) } ?? makeRequest(remoteURL, key: key)
            }.mapError {
                $0 as Any as! NSError // TODO: Big hack, revise flatMap to promoteError?
            }.flatMap {
                $0.responseData()
            }.map { _ -> NSURL in
                return self.localURLForKey(key)
            }.onComplete { r in
                // TODO: Thread-safety
                Log.debug("Download finished \(remoteURL) success: \(r.value != nil)")
                self.futuresByKey[key] = nil
                Async.main {
                    NSNotificationCenter.defaultCenter().postNotificationName(DownloadSuccessNotification, object: self)
                }
            }
        }
        return futuresByKey[key]!
    }
    
    public func pauseDownloadFile(remoteURL: NSURL) -> Future<(), NoError> {
        let key = self.keyForURL(remoteURL)
        if let request = self.getRequest(key) {
            let promise = Promise<(), NoError>()
            request.response { _, _, data, _ in
//                if let data = data {
                self.resumeDataCache.setValue(data as! NSData, key: key).onSuccess { _ in
                    promise.success()
                }
//                } else {
//                    promise.success()
//                }
            }
            request.cancel()
            return promise.future
        }
        return Future.succeeded()
    }
    
    public func fetchFile(remoteURL: NSURL) -> NSURL? {
        let localURL = localURLForRemoteURL(remoteURL)
        if let path = localURL.path where NSFileManager().fileExistsAtPath(path) {
            return localURL
        }
        return nil
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
    
    public func localURLForRemoteURL(remoteURL: NSURL) -> NSURL {
        return localURLForKey(keyForURL(remoteURL))
    }
    
    private func getRequest(key: String) -> Request? {
        return requestsByKey[key]
    }
    
    private func makeRequest(remoteURL: NSURL, key: String) -> Future<Request, NoError> {
        let dest: (NSURL, NSURLResponse) -> NSURL = { [weak self] tempURL, response in
            return self?.localURLForKey(key) ?? tempURL
        }
        Log.debug("Will make request to \(remoteURL)")
        return perform {
            resumeDataCache.pop(key)
        }.map {
            self.alamo.download($0, destination: dest)
        }.recover { _ in
            self.alamo.download(.GET, remoteURL, destination: dest)
        }.map {
            $0.validate()
        }.onSuccess { request in
            // TODO: Serialize data strucure access
            self.requestsByKey[key] = request
            request.responseData().onComplete { _ in
                self.requestsByKey[key] = nil
            }
        }
    }
    
    public func keyForURL(url: NSURL) -> String {
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
