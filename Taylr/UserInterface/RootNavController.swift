//
//  RootNavController.swift
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

class RootNavController : UINavigationController {
    var transitionManager : TransitionManager!

    let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
    let main = UIStoryboard(name: "Main", bundle: nil)
    
    init(account: AccountService) {
        let sb = account.hasAccount() ? main : onboarding
        super.init(rootViewController: sb.instantiateInitialViewController() as! UIViewController)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        transitionManager = TransitionManager(navigationController: self)
        
        UINavigationBar.appearance().barTintColor = StyleKit.brandPurple
        UINavigationBar.appearance().tintColor = StyleKit.textWhite
        UINavigationBar.appearance().titleTextAttributes = [
            NSFontAttributeName: UIFont(.cabinMedium, size: 20),
            NSForegroundColorAttributeName: StyleKit.textWhite
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont(.cabinRegular, size: 16)
        ], forState: .Normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(.cabinRegular, size: 14)
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
