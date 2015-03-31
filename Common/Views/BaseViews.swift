//
//  BaseViews.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable var borderColor: UIColor {
        get { return UIColor(CGColor: layer.borderColor) }
        set { layer.borderColor = newValue.CGColor }
    }
    
    @IBInspectable var shadowColor: UIColor {
        get { return UIColor(CGColor: layer.shadowColor) }
        set { layer.shadowColor = newValue.CGColor }
    }
}

class BaseView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() { }
}

class TransparentView : BaseView {
    
    @IBInspectable var passThroughTouchOnSelf : Bool = true
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if super.pointInside(point, withEvent: event) {
            if !passThroughTouchOnSelf {
                return true
            }
            for subview in subviews as [UIView] {
                if !subview.hidden &&
                    subview.pointInside(convertPoint(point, toView: subview), withEvent: event) {
                        return true
                }
            }
        }
        return false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = nil
    }
}

class IntrinsicSizeCollectionView : UICollectionView {
    override func layoutSubviews() {
        super.layoutSubviews()
        if (bounds.size != intrinsicContentSize()) {
//            println("Invalidating intrinsic size bounds: \(bounds.size) intrinsic \(intrinsicContentSize())")
            invalidateIntrinsicContentSize()
        }
    }
    override func intrinsicContentSize() -> CGSize {
        let size =  collectionViewLayout.collectionViewContentSize()
//        println("Intrinsic size is \(size)")
        return size
    }
}