//
//  BaseViews.swift
//  Taylr
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit

public class BaseView : UIView {

    public convenience init() {
        self.init(frame: CGRectZero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
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
            for subview in subviews {
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
        if let contentView = subviews.first {
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

public extension UIScrollView {
    public func scrollToTop(animated animated: Bool) {
        setContentOffset(CGPointMake(0, -contentInset.top), animated: animated)
    }
}

@IBDesignable public class NibDesignableView : BaseView {
    
    override public func commonInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: self.nibName(), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        insertSubview(view, atIndex: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.makeEdgesEqualTo(self)
    }
    
    func nibName() -> String {
        return self.dynamicType.description().componentsSeparatedByString(".").last!
    }
}


@IBDesignable public class DesignableLabel : UILabel {
    
    @IBInspectable public var fontSize: CGFloat = 13.0
    @IBInspectable public var fontName: String = "Cabin-Regular"
    @IBInspectable public var fontKern: CGFloat = 0
    
    public var rawText : String? {
        get { return attributedText?.string }
        set { attributedText = attributedText?.replace(text: newValue ?? "") }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont(name: fontName, size: fontSize)!
        attributedText = attributedText?.replace(font: font, kern: fontKern)
    }
}

@IBDesignable public class DesignableButton : UIButton {
    @IBInspectable public var fontSize: CGFloat = 13.0
    @IBInspectable public var fontName: String = "Cabin-Regular"
    @IBInspectable public var fontKern: CGFloat = 0
    
    public var attributedText : NSAttributedString? {
        get { return attributedTitleForState(.Normal) }
        set { setAttributedTitle(newValue, forState: .Normal) }
    }
    
    public var rawText : String? {
        get { return attributedText?.string }
        set { attributedText = attributedText?.replace(text: newValue ?? "") }
    }
    
    public var text : String? {
        get { return titleForState(.Normal) }
        set { setTitle(newValue, forState: .Normal) }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont(name: fontName, size: fontSize)!
        attributedText = attributedText?.replace(font: font, kern: fontKern)
    }
    
    public override func intrinsicContentSize() -> CGSize {
        let s = super.intrinsicContentSize()
        return CGSize(
            width: s.width + titleEdgeInsets.left + titleEdgeInsets.right,
            height: s.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        )
    }
}
