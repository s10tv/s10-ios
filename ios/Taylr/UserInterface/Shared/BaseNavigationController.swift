//
//  BaseNavigationController.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit

class BaseNavigationController : UINavigationController {
    
    let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
    let main = UIStoryboard(name: "Main", bundle: nil)
//    var transitionManager : TransitionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // http://stackoverflow.com/questions/19833939/uinavigationcontoller-interactivepopgesturerecognizer-inactive-when-navigation-b
        interactivePopGestureRecognizer?.delegate = nil
        navigationBar.barTintColor = StyleKit.brandPurple
        navigationBar.tintColor = StyleKit.textWhite
        navigationBar.titleTextAttributes = [
            NSFontAttributeName: UIFont(.cabinMedium, size: 20),
            NSForegroundColorAttributeName: StyleKit.textWhite
        ]
        
//        transitionManager = TransitionManager(navigationController: self)
        
        if let t = title where viewControllers.count == 0,
            let vc = UIStoryboard(name: t, bundle: nil).instantiateInitialViewController() {
                viewControllers = [vc]
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: Target Action
    
    @IBAction func goBack(sender: AnyObject) {
        if let vc = presentedViewController {
            vc.dismissViewController(animated: true)
        } else {
            popViewControllerAnimated(true)
        }
    }
    
    @IBAction func goToLogin() {
        viewControllers = [onboarding.instantiateInitialViewController()!]
    }    
}
