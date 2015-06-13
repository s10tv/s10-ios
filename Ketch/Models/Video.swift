//
//  Video.swift
//  Serendipity
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Video)
class Video: _Video {

    var coverFrameURL : NSURL? {
        return NSURL(coverFrameUrl!)
    }

}
