//
//  Bond+SDWebImage.swift
//  S10
//
//  Created by Tony Xiao on 6/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import SDWebImage
import ReactiveCocoa
import Core

var kPlaceholderImage: UInt8 = 0;

extension UIImageView {
    public var rac_image: Event<Image?, NoError>.Sink {
        return Event.sink(next: { [weak self] in self?.bindImage($0) })
    }
    
    public var placeholderImage: UIImage? {
        get { return objc_getAssociatedObject(self, &kPlaceholderImage) as? UIImage }
        set { objc_setAssociatedObject(self, &kPlaceholderImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    public func bindImage(image: Image?) {
        sd_cancelCurrentImageLoad()
        if let image = image?.image {
            self.image = image
        } else if let url = image?.url {
            sd_setImageWithURL(url, placeholderImage: placeholderImage)
        } else {
            self.image = placeholderImage
        }
    }
    
    public func unbindImage() {
        self.image = placeholderImage
        sd_cancelCurrentImageLoad()
    }
}

