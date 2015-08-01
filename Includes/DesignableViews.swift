//
//  Label.swift
//  Taylr
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit

@IBDesignable public class NibDesignableView : BaseView {
    
    override public func commonInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: self.nibName(), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        insertSubview(view, atIndex: 0)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
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
    
    public var rawText : String! {
        get { return attributedText.string }
        set { attributedText = attributedText.replace(text: newValue ?? "") }
    }

    public override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont(name: fontName, size: fontSize)!
        attributedText = attributedText.replace(font: font, kern: fontKern)
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
