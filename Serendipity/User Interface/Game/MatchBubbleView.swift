//
//  ProfileBubbleView.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/14/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class MatchBubbleView : UIImageView {
    
    var match : Match? {
        didSet {
            sd_setImageWithURL(match?.user?.profilePhotoURL)
        }
    }
}