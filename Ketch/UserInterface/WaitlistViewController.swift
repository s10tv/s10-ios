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
        allowedStates = [.Waitlist]
        screenName = "Waitlist"
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.Main_Chat.rawValue {
            if Connection.crabConnection() == nil {
                showAlert(LS(.ketchyUnavailableTitle), message: LS(.ketchyUnavailableMessage))
                return false
            }
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destVC as? ChatViewController {
            chatVC.connection = Connection.crabConnection()
        }
    }
}
