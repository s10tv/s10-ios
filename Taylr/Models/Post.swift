//
//  Post.swift
//  Serendipity
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

@objc(Post)
class Post: _Post {

	// Custom logic goes here.

    class func feed() {
        Post.all().fetch()
    }
}
