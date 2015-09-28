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


class RootNavController : UINavigationController {

    let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
    let main = UIStoryboard(name: "Main", bundle: nil)
    var transitionManager : TransitionManager!
    let vm = RootNavViewModel(meteor: Meteor)
    
    init(account: AccountService) {
        let sb = account.state.value.onboardingNeeded ? onboarding : main
        super.init(rootViewController: sb.instantiateInitialViewController()!)
    }
    
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
        
        transitionManager = TransitionManager(navigationController: self)
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
    
    // MARK: - Required init overrides
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
