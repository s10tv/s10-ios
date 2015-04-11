//
//  TransparentBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/4/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@IBDesignable class TransparentBackgroundView : TransparentView {
    
    @IBInspectable var waveTop : CGFloat = -1
    @IBInspectable var waveBottom : CGFloat = -1
    @IBInspectable var waveRatio : CGFloat = -1
    @IBInspectable var showBoat : Bool = false
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        backgroundColor = UIColor(hex: 0xF0FAF7)
        
        var offset : CGFloat = 0
        if waveTop > 0 {
            offset = waveTop
        } else if waveBottom > 0 {
            offset = bounds.height - waveBottom
        } else if waveRatio > 0 {
            offset = bounds.height * waveRatio
        }
        
        var frame = bounds
        frame.origin.y += offset
        frame.size.height -= offset
        addSubview(WaveView(frame: frame))
        if showBoat {
            let boatImage = UIImage(named: R.KetchAssets.ketch.rawValue,
                                    inBundle: NSBundle(forClass: self.dynamicType),
                                    compatibleWithTraitCollection: self.traitCollection)
            let boat = UIImageView(image: boatImage)
            boat.sizeToFit()
            boat.center = CGPoint(x: frame.midX, y: frame.minY - 15)
            addSubview(boat)
        }
    }
}