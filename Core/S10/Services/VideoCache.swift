//
//  VideoCache.swift
//  S10
//
//  Created by Tony Xiao on 7/11/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public class VideoCache {
    let fm = NSFileManager()
    public let cacheDir: NSURL
    
    public init(cacheDir: NSURL) {
        self.cacheDir = cacheDir
    }
    
    public func cacheURLForVideo(videoId: String) -> NSURL {
        return cacheDir.URLByAppendingPathComponent("\(videoId).mp4")
    }
    
    public func hasVideo(videoId: String) -> Bool {
        return fm.fileExistsAtPath(cacheURLForVideo(videoId).path!)
    }
    
    public func getVideo(videoId: String) -> NSURL? {
        return hasVideo(videoId) ? cacheURLForVideo(videoId) : nil
    }
    
    public func setVideo(videoId: String, fileURL: NSURL) -> NSError? {
        // Remove current if exists
        removeVideo(videoId)
        var error: NSError?
        fm.linkItemAtURL(fileURL, toURL: cacheURLForVideo(videoId), error: &error)
        return error
    }
    
    public func removeVideo(videoId: String) {
        fm.removeItemAtURL(cacheURLForVideo(videoId), error: nil)
    }
    
    public static let sharedInstance: VideoCache = {
        let fm = NSFileManager()
        let cachesDir = fm.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        let dir = cachesDir.URLByAppendingPathComponent("Videos")
        fm.createDirectoryAtURL(dir, withIntermediateDirectories: true, attributes: nil, error: nil)
        return VideoCache(cacheDir: dir)
    }()
}