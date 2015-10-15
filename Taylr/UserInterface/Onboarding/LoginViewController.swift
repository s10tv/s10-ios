//
//  LoginViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import JBKenBurnsView
import Foundation
import PKHUD
import DigitsKit
import ReactiveCocoa
import Meteor
import Core

class LoginViewController : BaseViewController, TutorialViewController {

    var index = 0
    @IBOutlet weak var loginButton: DesignableButton!
    @IBOutlet weak var logoutButton: UIButton!
    
    let vm = LoginViewModel(MainContext, delegate: Globals.accountService)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clearColor()

        loginButton.rac_title <~ vm.loginButtonText
        logoutButton.rac_title <~ vm.logoutButtonText

        loginButton.addAction(vm.loginAction) { values, errors, executing in
            showProgress <~ executing
            showErrorAction <~ errors.map { $0 as AlertableError }
            segueAction <~ values.filter { $0 != .LoggedOut }.map {
                Analytics.track("VerifyPhone")
                switch $0 {
                case .LoggedIn: return .LoginToRegisterEmail
                case .LoggedInButCodeDisabled: return .LoginToConnectServices
                case .Onboarded: return .Main_RootTab
                    // TODO: Fix me perma crash...
                default: fatalError("Expecting either LoggedIn or Onboarded")
                }
            }
        }
        loginButton.addTarget(self, action: "didPressLogin:", forControlEvents: .TouchDown)
        logoutButton.addAction(vm.logoutAction) { _, _, _ in }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Analytics.track("View: Welcome")
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
    
    @IBAction func didPressLogin(sender: AnyObject) {
        Analytics.track("Welcome: TapLoginWithPhone")
    }
    
    @IBAction func viewTerms(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.termsAndConditionURL)
    }
    
    @IBAction func viewPrivacy(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(vm.privacyURL)
    }

    // MARK: Tutorial View Protocol

    func getViewController() -> UIViewController {
        return self as UIViewController
    }

    func getIndex() -> Int {
        return index
    }

}