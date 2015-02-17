//
//  ProfileBubbleView.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/14/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class MatchBubbleView : UIImageView {
    
    var candidate : Candidate? {
        didSet {
            sd_setImageWithURL(candidate?.user?.profilePhotoURL)
            if candidate?.user?.profilePhotoURL == nil {
                image = UIImage(named: "girl-placeholder")
            }
        }
    }
}