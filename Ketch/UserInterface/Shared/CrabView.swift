//
//  CrabView.swift
//  Ketch
//
//  Created by Tony Xiao on 4/20/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class CrabView : UIButton {
    
    @IBInspectable var waveFlag: Bool = false { didSet { updateImage() } }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        if let crabConnection = Connection.crabConnection() {
            RACObserve(crabConnection, ConnectionAttributes.hasUnreadMessage.rawValue)
                .takeUntil(self.rac_willDeallocSignal()).subscribeNextAs { [weak self] (hasUnread: Bool) in
                self!.waveFlag = hasUnread
            }
        } else {
            updateImage()
        }
    }
    
    private func updateImage() {
        let imageName = waveFlag ? "ketchyFlagWave_" : "ketchyNeutral_"
        setImage(UIImage.animatedImageNamed(imageName, duration: 3), forState: .Normal)
    }
}