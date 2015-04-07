//
//  UserAvatarView.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/14/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class UserAvatarView : UIImageView {
    
    // Workaround for swift compiler
    override init(image: UIImage? = nil) {
        super.init(image: image)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override var frame: CGRect {
        didSet { makeCircular() }
    }
    
    private let fadeLayer : CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.clearColor().CGColor,
            UIColor.clearColor().CGColor,
            StyleKit.brandAlt.colorWithAlpha(0.75).CGColor,
            StyleKit.brandAlt.colorWithAlpha(0.9).CGColor,
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
                image = UIImage(named: R.ImagesAssets.girlPlaceholder)
            }
        }
    }
    
    var didTap : ((user: User?) -> Void)? {
        didSet {
            whenTapped { [weak self] in
                if let block = self?.didTap {
                    block(user: self?.user)
                }
            }
        }
    }
    
    // MARK: -
    // TODO: Non-nib-specific init?
    override func awakeFromNib() {
        super.awakeFromNib()
        userInteractionEnabled = true
        contentMode = .ScaleToFill
        image = UIImage(named: R.ImagesAssets.girlPlaceholder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        makeCircular()
        fadeLayer.frame = layer.bounds
    }
}