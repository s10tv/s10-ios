//
//  Video.swift
//  Serendipity
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Bond

@objc(Video)
public class Video: _Video {
    
    public var URL: Dynamic<NSURL?> {
        return self.dynValue(VideoKeys.url).map { NSURL.fromString($0) }
    }

}
