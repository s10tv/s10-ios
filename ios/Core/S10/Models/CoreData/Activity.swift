//
//  Activity.swift
//  S10
//
//  Created on 1/20/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

@objc(Activity)
internal class Activity: _Activity {
    enum ContentType : String {
        case Text = "text"
        case Image = "image"
        case Video = "video"
        case Link = "link"
    }
    
    func profile() -> User.ConnectedProfile? {
        // TODO: Consider memoizing with a dictionary
        for profile in (user?.connectedProfiles ?? []) {
            if profile.id == profileId {
                return profile
            }
        }
        return nil
    }

    var image: Image {
        return Image.mapper.map(image_)!
    }
    
    var type: ContentType? {
        return ContentType(rawValue: type_)
    }
    
    var url: NSURL? {
        return url_.flatMap { NSURL($0) }
    }

}
