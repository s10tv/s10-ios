//
//  ErrorViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/20/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ErrorViewController : CloudsViewController {
    
    @IBOutlet weak var errorLabel: DesignableLabel!
    @IBOutlet weak var recoveryButton: DesignableButton!
    
    var error: NSError?
    
    override func commonInit() {
        allowedStates = [.Error]
        screenName = "Error"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Reactify me?
        if let error = error {
            errorLabel.rawText = error.localizedDescription
            recoveryButton.hidden = !error.recoverable
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if identifier == SegueIdentifier.ErrorToCrab.rawValue {
            if Connection.crabConnection() == nil {
                showAlert(LS(.ketchyUnavailableTitle), message: LS(.ketchyUnavailableMessage))
                return false
            }
        }
        return super.shouldPerformSegueWithIdentifier(identifier, sender: sender)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let chatVC = segue.destinationViewController as? ChatViewController {
            chatVC.connection = Connection.crabConnection()
        }
    }

    // MARK: - Actions
    
    @IBAction func logout(sender: AnyObject) {
        Globals.accountService.logout()
    }
}