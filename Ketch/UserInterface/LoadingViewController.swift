//
//  LoadingViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class LoadingViewController : BaseViewController {
    
    override func commonInit() {
        waterlineLocation = .Bottom(60)
        hideKetchBoat = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /*
        1) Not logged in -> go to signup
        2) Not vetted -> go to waitlist
        3) Not accepted -> go to acceptance screen
        4) Has new match -> go to new match screen
        5) Has new message -> go to chat screen
        6) Has new game -> go to game screen
        7) Else -> Go to boat has sailed screen
        */
        Core.flow.getStateMatching({ $0 != .Loading }) { state in
            switch state {
            case .Signup:
                self.performSegue(.Signup_)
            case .Waitlist:
                self.performSegue(.Signup_Waitlist)
            case .Approval:
                break
            case .NewMatch(_):
                self.performSegue(.LoadingToNewConnection)
            case .NewGame(_, _, _):
                self.performSegue(.LoadingToGame)
            case .BoatSailed:
                self.performSegue(.LoadingToNoGame)
            case .Loading:
                assert(false, "Cannot transition from loading to loading state")
                break
            }
        }
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