//
//  NoGameViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class NoGameViewController : BaseViewController {
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        if edge == .Right {
            performSegue(.NoGameToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Core.flow.getStateMatching({ $0 != .BoatSailed }) { _ in
            self.performSegue(.NoGameToLoading)
            return
        }
    }
}