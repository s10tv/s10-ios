//
//  ReactiveBindings.swift
//  S10
//
//  Created by Tony Xiao on 6/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SDWebImage
import JSBadgeView
import Core

private var kPlaceholderImage: UInt8 = 0
private var kImage: UInt8 = 0

extension UIImageView {
    // TODO: Wrap placeholderImage directly into Image class
    public var placeholderImage: UIImage? {
        get { return objc_getAssociatedObject(self, &kPlaceholderImage) as? UIImage }
        set { objc_setAssociatedObject(self, &kPlaceholderImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    public var rac_image: MutableProperty<Image?> {
        return associatedObject(&kImage) { [weak self] in
            let property = MutableProperty<Image?>(nil)
            property.producer.startWithNext { [weak self] image in
                self?.sd_cancelCurrentImageLoad()
                if let image = image?.image {
                    self?.image = image
                } else if let url = image?.url {
                    self?.sd_setImageWithURL(url, placeholderImage: self?.placeholderImage) { image, error, cacheType, url in
                        if let error = error {
                            Log.warn("Unable to load image at \(url) \(error)")
                        }
                    }
                } else {
                    self?.image = self?.placeholderImage
                }
            }
            return property
        }
    }
}

private var kBadgeText: UInt8 = 0

extension JSBadgeView {
    public var rac_badgeText: MutableProperty<String> {
        return associatedProperty(&kBadgeText, setter: { self.badgeText = $0 }, getter: { self.badgeText ?? "" })
    }
}
