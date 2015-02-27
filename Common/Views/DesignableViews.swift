//
//  Label.swift
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

    override func awakeFromNib() {
        let attrString = NSMutableAttributedString(attributedString: attributedText)
        let range = NSMakeRange(0, attrString.length)
        attrString.addAttribute(NSFontAttributeName,
            value:UIFont(name: fontName, size: fontSize)!, range: range)
        attrString.addAttribute(NSKernAttributeName,
            value:fontKern, range: range)
        attributedText = attrString
    }

    func setRawText(rawText: String) {
        let attrString = attributedText.mutableCopy() as NSMutableAttributedString
        attrString.mutableString.setString(rawText)
        attributedText = attrString
    }
}

@IBDesignable class DesignableButton : UIButton {
    
}