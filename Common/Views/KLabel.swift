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

    override func awakeFromNib() {
        let attrString = NSMutableAttributedString(attributedString: self.attributedText)
        attrString.addAttribute(NSFontAttributeName,
            value: UIFont(name: self.fontName, size: self.fontSize)!,
            range: NSMakeRange(0, attrString.length))
        self.attributedText = attrString
    }
}