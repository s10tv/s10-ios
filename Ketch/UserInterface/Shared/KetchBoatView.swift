//
//  KetchBoatView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/14/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class KetchBoatView : UIImageView {
    
    override var image : UIImage? {
        get { return super.image }
        set { super.image = newValue ?? UIImage(R.KetchAssets.ketch) }
    }
    
    func animatePitch() {
        layer.animate(keyPath: "transform.rotation") { pitch, _ in
            pitch.fromValue = 0.2
            pitch.toValue = -0.2
            pitch.autoreverses = true
            pitch.duration = 3
            pitch.repeatCount = Float.infinity
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        animatePitch()
    }
}