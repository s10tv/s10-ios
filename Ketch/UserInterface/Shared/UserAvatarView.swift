//
//  UserAvatarView.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/14/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class UserAvatarView : UIImageView {
    private var fadeLayer : CAGradientLayer!
    
    var fadeRatio : CGFloat = 0 {
        didSet {
            // Ketchy should not show any indication of drowining
            if (fadeRatio > 1) {
                layer.addSublayer(fadeLayer)
                fadeLayer.locations = [0, 1, 1, 1]
                return
            }
            
            layer.addSublayer(fadeLayer)
            let ratio = between(0, fadeRatio, 1)
            fadeLayer.locations = [0, max(0, ratio-0.15), min(1, ratio+0.05), 1]
        }
    }
    
    var user : User? { didSet {
        if let photoURL = user?.profilePhotoURL {
            sd_setImageWithURL(photoURL)
        } else {
            image = UIImage(R.KetchAssets.girlPlaceholder)
        }
    } }

    // MARK: -
    
    // Workaround for swift compiler bug
    override init(image: UIImage? = nil) {
        super.init(image: image)
        commonInit()
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        userInteractionEnabled = true
        contentMode = .ScaleAspectFill
        fadeLayer = CAGradientLayer()
        fadeLayer.colors = [
            UIColor.clearColor().CGColor,
            UIColor.clearColor().CGColor,
            StyleKit.brandAlt.colorWithAlpha(0.75).CGColor,
            StyleKit.brandAlt.colorWithAlpha(0.9).CGColor,
        ]
        makeCircular()
    }
    
    // MARK: -
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 2
        fadeLayer.frame = layer.bounds
    }
}