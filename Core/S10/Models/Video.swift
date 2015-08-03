//
//  Video.swift
//  S10
//
//  Created by Tony Xiao on 7/25/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Video : Mappable {
    public var url: NSURL!
    public var duration: NSTimeInterval?
    public var width: Int?
    public var height: Int?
    
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
    
    init() {
    }
    
    public mutating func mapping(map: Map) {
        url <- (map["url"], URLTransform())
        duration <- map["duration"]
        width <- map["width"]
        height <- map["height"]
    }
    
    public static func newInstance() -> Mappable {
        return Video()
    }
    
    public static let mapper = Mapper<Video>()
}

extension Video : Printable {
    public var description: String {
        return "Video[url=\(url), w=\(width) h=\(height)]"
    }
}
