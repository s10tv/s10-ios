//
//  Bond+SDWebImage.swift
//  S10
//
//  Created by Tony Xiao on 6/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Bond
import SDWebImage
import Core

var imageURLDynamicHandleUIImageView: UInt8 = 0;
var placeholderimageDynamicHandleUIImageView: UInt8 = 0;

extension UIImageView {
    public var dynPlaceholderImage: UIImage? {
        get {
            return objc_getAssociatedObject(self, &placeholderimageDynamicHandleUIImageView) as? UIImage
        }
        set {
            objc_setAssociatedObject(self, &placeholderimageDynamicHandleUIImageView,
                newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    public var dynImageURL: Dynamic<NSURL?> {
        if let d: AnyObject = objc_getAssociatedObject(self, &imageURLDynamicHandleUIImageView) {
            return (d as? Dynamic<NSURL?>)!
        } else {
            let d = InternalDynamic<NSURL?>(self.sd_imageURL())
            let bond = Bond<NSURL?>() { [weak self] v in if let s = self { s.sd_setImageWithURL(v, placeholderImage: s.dynPlaceholderImage) } }
            d.bindTo(bond, fire: false, strongly: false)
            d.retain(bond)
            objc_setAssociatedObject(self, &imageURLDynamicHandleUIImageView, d, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
            return d
        }
    }
    
    public func unbindDynImageURL() {
        dynImageURL.valueBond.unbindAll()
        sd_cancelCurrentImageLoad()
    }
    
    public func bindImage(image: Image?) {
        sd_cancelCurrentImageLoad()
        if let image = image?.image {
            self.image = image
        } else if let url = image?.url {
            sd_setImageWithURL(url)
        } else {
            self.image = nil
        }
    }
}

