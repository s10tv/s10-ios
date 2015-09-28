//
//  TouchDetector.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit.UIGestureRecognizerSubclass

class TouchDetector: UIGestureRecognizer {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if enabled {
            state = .Began
        }
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if enabled {
            state = .Ended
        }
    }
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if enabled {
            state = .Ended
        }
    }
}
