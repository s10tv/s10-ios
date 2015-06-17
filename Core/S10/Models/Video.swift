//
//  Video.swift
//  Serendipity
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Video)
public class Video: _Video {

    public var coverFrameURL : NSURL? {
        return coverFrameUrl.map { NSURL($0) } ?? nil
    }
    
    public var URL: NSURL? {
        return url.map { NSURL($0) } ?? nil
    }

}
