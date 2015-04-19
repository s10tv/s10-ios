//
//  BoatSailedViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/5/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class BoatSailedViewController : HomeViewController {
    
    override func commonInit() {
        allowedStates = [.BoatSailed]
    }
        
    @IBAction func nominateFriend(sender: AnyObject) {
        let inviteText = LS(.inviteDefaultText)
        let activity = UIActivityViewController(activityItems: [inviteText], applicationActivities: nil)
        presentViewController(activity)
    }
}