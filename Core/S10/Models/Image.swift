//
//  Image.swift
//  S10
//
//  Created by Tony Xiao on 7/10/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Argo
import Runes

extension NSURL : Decodable {
    public static func decode(json: JSON) -> Decoded<NSURL> {
        switch json {
        case let .String(s): return .fromOptional(NSURL(string: s))
        default: return .TypeMismatch("\(json) is not a string")
        }
    }
}

public struct Image {
    public let url: NSURL
    public let width: Int?
    public let height: Int?
    
    public static func fromDict(dict: NSDictionary) -> Image? {
        if let width = dict["width"] as? Int,
            let height = dict["height"] as? Int,
            let url = NSURL.fromString(dict["url"] as? String) {
            return Image(url: url, width: width, height: height)
        }
        return nil
    }
}

extension Image : Printable {
    public var description: String {
        return "Image[url=\(url), w=\(width) h=\(height)]"
    }
}

extension Image : Decodable {
    static func create(url: NSURL)(width: Int?)(height: Int?) -> Image {
        return Image(url: url, width: width, height: height)
    }
    
    public static func decode(json: JSON) -> Decoded<Image> {
        return create
            <^> json <| "url"
            <*> json <|? "width"
            <*> json <|? "height"
    }
}