//
//  Resources.swift
//  Ketch
//
//  Created by Tony Xiao on 4/4/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

// TODO: Autogenerate this enum from project file so it does not have
// to be manually kept up to date. 
// https://app.asana.com/0/30813404221323/30864998169005

enum FontName : String {
    case KetchIcon = "KetchIcon"
    case TransatTextLight    = "TransatTextLight"
    case TransatTextMedium   = "TransatTextMedium"
    case TransatTextStandard = "TransatTextStandard"
    case TransatTextBold     = "TransatTextBold"
    case TransatTextBlack    = "TransatTextBlack"
}

extension UIFont {
    convenience init!(_ fontName: FontName, size: CGFloat) {
        self.init(name: fontName.rawValue, size: size)
    }
}