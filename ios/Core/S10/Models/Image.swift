//
//  Image.swift
//  S10
//
//  Created by Tony Xiao on 7/10/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation

public struct Image {
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
        // TODO: Check if this is ok in general
        self.width = Int(image.size.width * image.scale)
        self.height = Int(image.size.height * image.scale)
    }
}

extension Image : CustomStringConvertible {
    public var description: String {
        return "Image[url=\(url), w=\(width) h=\(height)]"
    }
}
