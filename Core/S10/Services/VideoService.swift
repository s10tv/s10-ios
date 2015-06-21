//
//  VideoService.swift
//  S10
//
//  Created by Tony Xiao on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public class VidMessageTask {
    public var taskId: String!
    public var localURL: NSURL!
    public var uploadURL: NSURL!
    public var createdAt: NSDate!
}

public class VideoService {
    let queue = NSOperationQueue()
    
    public func pendingTasks(recipient: User) -> [VidMessageTask] {
        return []
    }
    
    public func sendVideoMessage(recipient: User, localVideoURL: NSURL) -> VidMessageTask {
        return VidMessageTask()
    }
    
    public func getPlaybackURL(video: Video) -> NSURL {
        return NSURL()
    }
}

