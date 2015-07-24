//
//  Image.swift
//  S10
//
//  Created by Tony Xiao on 7/10/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ObjectMapper

public struct Image : Mappable {
    public var url: NSURL!
    public var image: UIImage?
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
    
    public init(_ image: UIImage) {
        self.image = image
    }
    
    public init?(_ map: Map) {
        mapping(map)
    }
    
    public mutating func mapping(map: Map) {
        url <- (map["url"], URLTransform())
        width <- map["width"]
        height <- map["height"]
    }
}

extension Image : Printable {
    public var description: String {
        return "Image[url=\(url), w=\(width) h=\(height)]"
    }
}
