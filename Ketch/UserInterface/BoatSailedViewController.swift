//
//  BoatSailedViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class BoatSailedViewController : BaseViewController {
    
    override func stateDidUpdateWhileViewActive(state: FlowService.State) {
        if state != .BoatSailed {
            self.performSegue(.BoatSailedToLoading)
        }
    }
    
    override func handleScreenEdgePan(edge: UIRectEdge) -> Bool {
        if edge == .Right {
            performSegue(.BoatSailedToDock)
            return true
        }
        return super.handleScreenEdgePan(edge)
    }
}