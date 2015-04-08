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
        
        Core.flow.getStateMatching({ $0 != .Loading }) { state in
            println("Got new state in loading \(state)")
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
            vc.connection = Core.flow.newConnectionToShow
            Core.flow.clearNewConnectionToShow()
        }
        if let vc = segue.destVC as? GameViewController {
            vc.candidates = Array(Core.flow.candidateQueue![0...2])
        }
    }
}