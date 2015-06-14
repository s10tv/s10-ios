//
//  BaseViews.swift
//  Taylr
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
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
    
    @IBInspectable var borderColor: UIColor? {
        get { return UIColor(CGColor: layer.borderColor) }
        set { layer.borderColor = newValue?.CGColor }
    }
    
    @IBInspectable var shadowColor: UIColor? {
        get { return UIColor(CGColor: layer.shadowColor) }
        set { layer.shadowColor = newValue?.CGColor }
    }
}

class BaseView : UIView {

    convenience init() {
        self.init(frame: CGRectZero)
    }
    
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
            for subview in subviews as! [UIView] {
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
    override var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                collectionViewLayout.invalidateLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        return collectionViewLayout.collectionViewContentSize()
    }
}

// NOTE: ContentScrollView sets the dimension of the content to be the same as the dimension of the
// scroll view in either vertical or horizontal dimension. The first subview is assumed to be the 
// content view which will have the same dimension in specified direction as the scroll view
class OneDScrollView : UIScrollView {
    @IBInspectable var verticalMode : Bool = true {
        didSet { setNeedsUpdateConstraints() }
    }
    
    private var dimensionConstraint : NSLayoutConstraint?
    
    override func updateConstraints() {
        if let constraint = dimensionConstraint {
            removeConstraint(constraint)
        }
        if let contentView = subviews.first as? UIView {
            let attribute : NSLayoutAttribute = verticalMode ? .Width : .Height
            dimensionConstraint = NSLayoutConstraint(
                item: self, attribute: attribute,
                relatedBy: .Equal,
                toItem: contentView, attribute: attribute,
                multiplier: 1, constant: 0)
            addConstraint(dimensionConstraint!)
        }
        super.updateConstraints()
    }
}
