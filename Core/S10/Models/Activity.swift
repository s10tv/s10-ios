//
//  Activity.swift
//  S10
//
//  Created on 6/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Bond

@objc(Activity)
public class Activity : _Activity {
    
    public enum Action : String {
        case Post = "post"
        case Like = "like"
    }

    public private(set) lazy var imageURL: Dynamic<NSURL?> = {
        return self.dynValue(ActivityKeys.imageUrl).map { NSURL.fromString($0) }
    }()
    
    public private(set) lazy var dynImage: Dynamic<Image?> = { // TOOD: Write a flatMap for dynamic / propertyOf
        return self.dynValue(ActivityKeys.image).map { $0.map { Image.fromDict($0) } ?? nil }
    }()
    
    public private(set) lazy var dynTimestamp: Dynamic<NSDate?> = {
        return self.dynValue(ActivityKeys.timestamp)
    }()
    
    public private(set) lazy var dynText: Dynamic<String?> = {
        return self.dynValue(ActivityKeys.text)
    }()
    
    public private(set) lazy var dynCaption: Dynamic<String?> = {
        return self.dynValue(ActivityKeys.caption)
    }()
    
    public private(set) lazy var dynAction: Dynamic<Action?> = {
        return self.dynValue(ActivityKeys.action).map { $0.map { Action(rawValue: $0) } ?? nil }
    }()
    
    public private(set) lazy var dynQuote: Dynamic<String?> = {
        return self.dynValue(ActivityKeys.caption)
    }()

}
