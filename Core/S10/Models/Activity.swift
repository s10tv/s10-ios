//
//  Activity.swift
//  S10
//
//  Created on 6/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Bond

@objc(Activity)
public class Activity: _Activity {

    public private(set) lazy var imageURL: Dynamic<NSURL?> = {
        return self.dynValue(ActivityKeys.imageUrl).map { NSURL.fromString($0) }
    }()

}
