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
        
        Core.candidateService.fetch.signal.subscribeNextAs { [weak self] (candidates : [Candidate]) in
            if let this = self {
                if candidates.count >= 3 {
                    this.performSegue(.LoadingToGame)
                } else {
                    this.performSegue(.LoadingToNoGame)
                }
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