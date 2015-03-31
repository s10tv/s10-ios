//
//  Label.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

@IBDesignable class NibDesignableView : BaseView {
    
    override func commonInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: self.nibName(), bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as UIView
        insertSubview(view, atIndex: 0)
        view.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.makeEdgesEqualTo(self)
    }
    
    func nibName() -> String {
        return self.dynamicType.description().componentsSeparatedByString(".").last!
    }
}


@IBDesignable class DesignableLabel : UILabel {

    @IBInspectable var fontSize: CGFloat = 13.0
    @IBInspectable var fontName: String = "TransatTextStandard"
    @IBInspectable var fontKern: CGFloat = 0
    
    var rawText : String {
        get { return attributedText.string }
        set(newValue) {
            let attrString = attributedText.mutableCopy() as NSMutableAttributedString
            attrString.mutableString.setString(newValue)
            attributedText = attrString
        }
    }

    override func awakeFromNib() {
        let attrString = NSMutableAttributedString(attributedString: attributedText)
        let range = NSMakeRange(0, attrString.length)
        attrString.addAttribute(NSFontAttributeName,
            value:UIFont(name: fontName, size: fontSize)!, range: range)
        attrString.addAttribute(NSKernAttributeName,
            value:fontKern, range: range)
        attributedText = attrString
    }
}

@IBDesignable class DesignableButton : UIButton {
    
}