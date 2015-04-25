//
//  SignupViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import PKHUD
import ReactiveCocoa
import Meteor

class SignupViewController : BaseViewController {

    @IBOutlet weak var fullLogo: UIImageView!
    
    override func commonInit() {
        allowedStates = [.Signup]
        screenName = "Signup"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullLogo.userInteractionEnabled = true
        fullLogo.whenLongPressEnded { [weak self] in self!.debugLogin(self!) }
    }
    
    private func startLogin(loginBlock: () -> RACSignal, errorBlock: (NSError?) -> ()) {
        // TODO: We need to think about holistic, not just adhoc error handling
        if !Meteor.networkReachable {
            showErrorAlert(NSError(.NetworkUnreachable))
            return
        }
        // Temp hack, timing issue
        allowedStates = [.Signup, .Waitlist, .Welcome]
        PKHUD.showActivity()
        loginBlock().subscribeError({ error in
            PKHUD.hide()
            errorBlock(error)
        }, completed: {
            PKHUD.hide()
            self.performSegue(.SignupToNotificationsPerm)
        })
    }
    
    // MARK: Actions
    
    @IBAction func didTapOnNotPicky(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.notPickyExitURL)
    }
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(Globals.env.privacyURL)
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        let current = Globals.env.audience
        let beta = Environment.Audience.Beta
        let prod = Environment.Audience.AppStore
        if (current == beta || current == prod) && beta.installed && prod.installed {
            showErrorAlert(NSError(.BetaProdBothInstalled))
            return
        }

        startLogin({ Globals.accountService.login() }, errorBlock: { error in
            // TODO: This us duplicated and can be refactored
            if let error = error {
                if error.domain == METDDPErrorDomain {
                    self.showAlert(LS(.errUnableToLoginTitle), message: LS(.errUnableToLoginMessage))
                    return
                }
            }
            self.performSegue(.SignupToFacebookPerm)
        })
    }
    
    @IBAction func debugLogin(sender: AnyObject) {
        Analytics.track("Debug Login Attempt")
        if !Meteor.settings.debugLoginMode {
            return
        }
        let alert = UIAlertController(title: "DEBUG LOGIN MODE", message: nil, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { textField in
            textField.placeholder = "Enter target userId"
        }
        alert.addAction("Cancel", style: .Cancel)
        alert.addAction("Login") { [weak alert] _ in
            if let userId = (alert?.textFields?.first as? UITextField)?.text?.nonBlank() {
                self.startLogin({ Globals.accountService.debugLogin(userId) }, errorBlock: { error in
                    self.showAlert("Failed to login", message: error?.localizedDescription ?? "Unknown Error")
                })
            }
        }
        presentViewController(alert)
    }
}