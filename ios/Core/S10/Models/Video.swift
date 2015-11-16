//
//  Video.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public struct Video {
    public var identifier: String!
    public var url: NSURL!
    public var duration: NSTimeInterval!
    public var width: Int?
    public var height: Int?
    public var thumbnail: Image?
    
    public init?(_ urlString: String?) {
        if let url = urlString.flatMap({ NSURL(string: $0) }) {
            self.url = url
        } else {
            return nil
        }
    }
    
    public init(_ url: NSURL) {
        self.url = url
    }
    
}

extension Video : CustomStringConvertible {
    public var description: String {
        return "Video[url=\(url), w=\(width) h=\(height)]"
    }
}
