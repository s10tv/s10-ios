//
//  RootViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import Meteor
import ReactiveCocoa
import Core
import Bond

extension UINavigationController {
    var lastViewController: UIViewController? {
        if viewControllers.count >= 2 {
            return viewControllers[viewControllers.count - 2] as? UIViewController
        }
        return nil
    }
}

class RootViewController : UINavigationController {
    var transitionManager : TransitionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitionManager = TransitionManager(navigationController: self)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(.cabinRegular, size: 14)
        ], forState: .Normal)
        
        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(.cabinMedium, size: 20),
            NSForegroundColorAttributeName: StyleKit.textWhite
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont(.cabinRegular, size: 16)
        ], forState: .Normal)
        
        // http://stackoverflow.com/questions/19833939/uinavigationcontoller-interactivepopgesturerecognizer-inactive-when-navigation-b
        interactivePopGestureRecognizer.delegate = nil
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Target Action
    
    @IBAction func goBack(sender: AnyObject) {
        if let vc = presentedViewController {
            dismissViewController(animated: true)
        } else {
            popViewControllerAnimated(true)
        }
    }
}
