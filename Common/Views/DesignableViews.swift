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
        set { attributedText = attributedText.replace(text: newValue) }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont(name: fontName, size: fontSize)!
        attributedText = attributedText.replace(font: font, kern: fontKern)
    }
}

@IBDesignable class DesignableButton : UIButton {
    @IBInspectable var fontSize: CGFloat = 13.0
    @IBInspectable var fontName: String = "TransatTextStandard"
    @IBInspectable var fontKern: CGFloat = 0
    
    var attributedText : NSAttributedString? {
        get { return attributedTitleForState(.Normal) }
        set { setAttributedTitle(newValue, forState: .Normal) }
    }
    
    var rawText : String? {
        get { return attributedText?.string }
        set { attributedText = attributedText?.replace(text: newValue ?? "") }
    }
    
    var text : String? {
        get { return titleForState(.Normal) }
        set { setTitle(newValue, forState: .Normal) }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let font = UIFont(name: fontName, size: fontSize)!
        attributedText = attributedText?.replace(font: font, kern: fontKern)
    }
}