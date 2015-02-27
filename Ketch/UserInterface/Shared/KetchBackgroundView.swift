//
//  KetchBackgroundView.swift
//  Ketch
//
//  Created by Tony Xiao on 2/26/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation
import NibDesignable

@IBDesignable class KetchBackgroundView : NibDesignableView {
    
    @IBOutlet weak var ketchIcon: UIImageView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var dockButton: UIButton!
    
}