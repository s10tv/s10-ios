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
        do {
            try fm.linkItemAtURL(fileURL, toURL: cacheURLForVideo(videoId))
        } catch let error as NSError {
            return error
        }
        return nil
    }
    
    public func removeVideo(videoId: String) {
        _ = try? fm.removeItemAtURL(cacheURLForVideo(videoId))
    }
    
    public static let sharedInstance: VideoCache = {
        let fm = NSFileManager()
        let cachesDir = fm.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        let dir = cachesDir.URLByAppendingPathComponent("Videos")
        _ = try? fm.createDirectoryAtURL(dir, withIntermediateDirectories: true, attributes: nil)
        return VideoCache(cacheDir: dir)
    }()
}