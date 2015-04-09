//
//  WaitlistViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class WaitlistViewController : CloudsViewController {
    
    override func commonInit() {
        hideKetchBoat = false
        waterlineLocation = .Ratio(0.55)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destVC as? ChatViewController {
            chatVC.connection = Connection.crabConnection()
        }
    }
    
}
