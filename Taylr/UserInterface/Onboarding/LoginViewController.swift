//
//  LoginViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import PKHUD
import DigitsKit
import ReactiveCocoa
import Meteor
import Bond
import Core

class LoginViewController : BaseViewController {

    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let vm = LoginViewModel(delegate: Globals.accountService)
    
    override func commonInit() {
        screenName = "Signup"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.loginButtonText ->> loginButton.titleBond
        vm.logoutButtonText ->> logoutButton.titleBond
        loginButton.whenLongPressEnded { [weak self] in self!.debugLogin(self!) }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? LinkedStoryboardPushSegue where segue.matches(.Main_RootTab) {
            segue.replaceStrategy = .Stack
        }
    }
    
    // MARK: Actions
    @IBAction func didTapLogout(sender: AnyObject) {
        vm.logout()
    }
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.privacyURL)
    }
    
    @IBAction func startLogin(sender: AnyObject) {
        if Meteor.connectionStatus.value != .Connected {
            showErrorAlert(NSError(.NetworkUnreachable))
            return
        }
        Globals.accountService.login()
            |> deliverOn(UIScheduler())
            |> onSuccess {
                assert(NSThread.isMainThread(), "Only on main")
                switch Globals.accountService.state.value {
                case .LoggedIn:
                    self.performSegue(.LoginToCreateProfile, sender: self)
                case .Onboarded:
                    self.performSegue(.Main_RootTab, sender: self)
                default:
                    assertionFailure("Expecting either LoggedIn or Onboarded")
                }
            }
            |> onFailure { error in
                if error.domain == METDDPErrorDomain {
                    self.showAlert(LS(.errUnableToLoginTitle), message: LS(.errUnableToLoginMessage))
                } else if error.domain == DGTErrorDomain {
                    // Ignoring digits error for now
                    Log.warn("Ignoring digits error, not handling for now \(error)")
                }
            }
    }
    
    // MARK; - Debugging
    
    private func startLogin(loginBlock: () -> RACSignal, errorBlock: (NSError?) -> ()) {
        // TODO: We need to think about holistic, not just adhoc error handling
        if Meteor.connectionStatus.value != .Connected {
            showErrorAlert(NSError(.NetworkUnreachable))
            return
        }
        PKHUD.showActivity()
        loginBlock().subscribeError({ error in
            PKHUD.hide()
            errorBlock(error)
            }, completed: {
                PKHUD.hide()
                self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    @IBAction func debugLogin(sender: AnyObject) {
        Analytics.track("Debug Login Attempt")
        if Globals.settings.debugLoginMode.value != true {
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