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


class RootNavController : UINavigationController {

    let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
    let main = UIStoryboard(name: "Main", bundle: nil)
    var transitionManager : TransitionManager!
    
    init(account: AccountService) {
        let sb = account.hasAccount() ? main : onboarding
        super.init(rootViewController: sb.instantiateInitialViewController() as! UIViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // http://stackoverflow.com/questions/19833939/uinavigationcontoller-interactivepopgesturerecognizer-inactive-when-navigation-b
        interactivePopGestureRecognizer.delegate = nil
        
        transitionManager = TransitionManager(navigationController: self)
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
    
    // MARK: - Required init overrides
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
