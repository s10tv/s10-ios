//
//  LoadingViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class LoadingViewController : BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waterlineLocation = .Bottom(60)
        hideKetchBoat = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("Loading view did appear")
        if !Core.attemptLoginWithCachedCredentials() {
            performSegue(.Signup_)
        } else {
            Core.connectionsSubscription.signal.deliverOnMainThread().subscribeCompleted {
                //                if User.currentUser()?.vetted == "yes" {
                //
                //                }
                //                self.performSegue(.LoadingToGame)
                self.performSegue(.LoadingToNewConnection)
            }
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destVC as? NewConnectionViewController {
            vc.connection = Connection.all().fetchFirst() as? Connection
        }
    }
}