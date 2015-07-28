//
//  LoadingViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

class LoadingViewController : UIViewController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Globals.accountService.state.producer
            |> skipWhile { $0 == AccountService.State.Indeterminate }
            |> futureSuccess(UIScheduler()) { state in
                assert(NSThread.isMainThread(), "Must be on main")
                switch state {
                case .LoggedOut:
                    self.performSegue(.Onboarding_Login, sender: self)
                case .LoggedIn:
                    self.performSegue(.Onboarding_CreateProfile, sender: self)
                case .SignedUp:
                    self.performSegue(.LoadingToRootTab, sender: self)
                default:
                    fatalError("impossible account status")
                }
//                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("Integrations") as! UIViewController
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = false
            segue.replaceStrategy = .Stack
            if let vc = segue.destinationViewController as? SignupViewController {
//                vc.vm = SignupViewModel(meteor: Meteor, user: Meteor.user.value!)
                // TODO: Move this type of stuff into the router
                let onboarding = UIStoryboard(name: "Onboarding", bundle: nil)
                let login = onboarding.instantiateInitialViewController() as! UIViewController
                segue.replaceStrategy = .BackStack([login])
            }
        }
    }
    
}