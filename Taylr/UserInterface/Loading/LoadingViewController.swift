//
//  LoadingViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/3/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
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
            |> toFuture
            |> deliverOn(UIScheduler())
            |> onSuccess { state in
                assert(NSThread.isMainThread(), "Must be on main")
                switch state {
                case .LoggedOut, .LoggedIn:
                    self.performSegue(.Onboarding_Login, sender: self)
                case .SignedUp:
                    self.performSegue(.LoadingToRootTab, sender: self)
                default:
                    fatalError("impossible account status")
                }
            }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = false
            segue.replaceStrategy = .Stack
        }
    }
    
}