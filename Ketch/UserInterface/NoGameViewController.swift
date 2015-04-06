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
}