//
//  BaseViews.swift
//  Taylr
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit

extension UIView {
    @IBInspectable public var cornerRadius: CGFloat {
        get { return layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get { return layer.borderWidth }
        set { layer.borderWidth = newValue }
    }
    
    @IBInspectable public var borderColor: UIColor? {
        get { return UIColor(CGColor: layer.borderColor) }
        set { layer.borderColor = newValue?.CGColor }
    }
    
    @IBInspectable public var shadowColor: UIColor? {
        get { return UIColor(CGColor: layer.shadowColor) }
        set { layer.shadowColor = newValue?.CGColor }
    }
}

public class BaseView : UIView {

    public convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public func commonInit() { }
}

public class TransparentView : BaseView {
    
    @IBInspectable public var passThroughTouchOnSelf : Bool = true
    
    public override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = nil
    }
}

public class IntrinsicSizeCollectionView : UICollectionView {
    public override var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                collectionViewLayout.invalidateLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return collectionViewLayout.collectionViewContentSize()
    }
}

// NOTE: ContentScrollView sets the dimension of the content to be the same as the dimension of the
// scroll view in either vertical or horizontal dimension. The first subview is assumed to be the 
// content view which will have the same dimension in specified direction as the scroll view
public class OneDScrollView : UIScrollView {
    @IBInspectable public var verticalMode : Bool = true {
        didSet { setNeedsUpdateConstraints() }
    }
    
    private var dimensionConstraint : NSLayoutConstraint?
    
    public override func updateConstraints() {
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
