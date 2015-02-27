//
//  UserAvatarView.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/14/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class UserAvatarView : UIImageView {
    
    private let fadeLayer : CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clearColor().CGColor,
            UIColor.clearColor().CGColor,
            UIColor(hex: 0x43dedc, andAlpha: 0.75).CGColor,
            UIColor(hex: 0x43dedc, andAlpha: 0.9).CGColor,
        ]
        return gradient
    }()
    
    var fadeRatio : CGFloat = 0 {
        didSet {
            layer.addSublayer(fadeLayer)
            let ratio = between(0, fadeRatio, 1)
            fadeLayer.locations = [0, max(0, ratio-0.15), min(1, ratio+0.05), 1]
        }
    }
    
    var user : User? {
        didSet {
            if let photoURL = user?.profilePhotoURL {
                sd_setImageWithURL(photoURL)
            } else {
                image = UIImage(named: "girl-placeholder")
            }
        }
    }
    
    var didTap : ((user: User?) -> Void)?;
    
    // MARK: -
    // TODO: Non-nib-specific init?
    override func awakeFromNib() {
        super.awakeFromNib()
        contentMode = .ScaleToFill
        userInteractionEnabled = true
        whenTapped { [weak self] in
            if let block = self?.didTap {
                block(user: self?.user)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircular()
        fadeLayer.frame = layer.bounds
    }
}