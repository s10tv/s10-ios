//
//  BaseTransition.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class RootTransition : ViewControllerTransition {
    let rootVC : RootViewController
    
    init(rootVC: RootViewController, fromVC: UIViewController, toVC: UIViewController, duration: NSTimeInterval = 0.6) {
        self.rootVC = rootVC
        super.init(fromVC: fromVC, toVC: toVC, duration: duration)
    }
}
