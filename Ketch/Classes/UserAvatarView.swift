//
//  UserAvatarView.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/14/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class UserAvatarView : UIImageView {
    
    let fadeLayer : CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clearColor().CGColor,
            UIColor.clearColor().CGColor,
            UIColor(hex: 0x43dedc, andAlpha: 0.6).CGColor,
            UIColor(hex: 0x43dedc, andAlpha: 0.9).CGColor,
        ]
        return gradient
    }()
    
    var fadeRatio : CGFloat = 0 {
        didSet {
            let ratio = between(0, fadeRatio, 1)
            fadeLayer.locations = [0, max(0, ratio-0.15), min(1, ratio+0.05), 1]
        }
    }
    
    var user : User? {
        didSet {
            sd_setImageWithURL(user?.profilePhotoURL)
            if user?.profilePhotoURL == nil {
                image = UIImage(named: "girl-placeholder")
            }
        }
    }
    
    // MARK: -
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.addSublayer(fadeLayer) // TODO: make this not nib dependent
        fadeRatio = 0.5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        fadeLayer.frame = layer.bounds
    }
}