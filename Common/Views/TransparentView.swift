//
//  TransparentView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class TransparentView : BaseView {
    
    @IBInspectable var passThroughTouchOnSelf : Bool = true
    
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        if super.pointInside(point, withEvent: event) {
            if !passThroughTouchOnSelf {
                return true
            }
            for subview in subviews as [UIView] {
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
