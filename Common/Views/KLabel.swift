//
//  KLabel.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

@IBDesignable class KAttributedLabel: UILabel {

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
}