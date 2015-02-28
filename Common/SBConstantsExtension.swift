//
//  SBConstantsExtension.swift
//  Ketch
//
//  Created by Tony Xiao on 2/28/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

extension UIStoryboard {
    func makeViewController(identifier: ViewControllerStoryboardIdentifier) -> UIViewController {
        return instantiateViewControllerWithIdentifier(identifier.rawValue) as UIViewController
    }
    func makeInitialViewController() -> UIViewController {
        return instantiateInitialViewController() as UIViewController
    }
}

extension UIViewController {
    func makeViewController(identifier: ViewControllerStoryboardIdentifier) -> UIViewController? {
        return storyboard?.makeViewController(identifier)
    }
    
    func performSegue(identifier: SegueIdentifier, sender: AnyObject?) {
        performSegueWithIdentifier(identifier.rawValue, sender: sender)
    }
    
    func performSegue(identifier: SegueIdentifier) {
        performSegue(identifier, sender: nil)
    }
}