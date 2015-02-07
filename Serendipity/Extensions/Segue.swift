//
//  Segue.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/6/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import QuartzCore

class PushFromLeftSegue : UIStoryboardSegue {
    
    override func perform() {
        if let navVC = (self.sourceViewController as UIViewController).navigationController {
            let transition = CATransition()
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromLeft
            navVC.view.layer.addAnimation(transition, forKey: kCATransition)
            navVC.pushViewController(destinationViewController as UIViewController, animated: false)
        }
    }
}
