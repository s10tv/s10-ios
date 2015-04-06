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

//        if !Core.attemptLoginWithCachedCredentials() {
//            performSegue(.Signup_)
//        } else {
//            Core.connectionsSubscription.signal.deliverOnMainThread().subscribeCompleted {
//                //                if User.currentUser()?.vetted == "yes" {
//                //
//                //                }
//                //                self.performSegue(.LoadingToGame)
////                self.performSegue(.LoadingToNewConnection)
//            }
        Core.candidateService.fetch.signal.subscribeNextAs { [weak self] (candidates : [Candidate]) in
            if let this = self {
                if candidates.count >= 3 {
                    this.performSegue(.LoadingToGame)
                } else {
                    this.performSegue(.LoadingToNoGame)
                }
            }
        }

//        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destVC as? NewConnectionViewController {
            vc.connection = Connection.all().fetchFirst() as? Connection
        }
        if let vc = segue.destVC as? GameViewController {
            let candidates = Core.candidateService.fetch.objects.map { $0 as Candidate }
            vc.candidates = Array(candidates[0...2])
        }
    }
}