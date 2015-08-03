//
//  UsernameViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Bond
import Core
import ReactiveCocoa

class UsernameViewController : UIViewController {
 
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let vm = UsernameViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.placeholder = vm.usernamePlaceholder
        vm.username <->> usernameField
        vm.statusImage ->> statusImageView.imageBond
        vm.hideSpinner ->> spinner.dynHidden
        vm.statusMessage ->> statusLabel
        vm.statusColor ->> statusLabel.dynTextColor
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        usernameField.becomeFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let segue = segue as? AdvancedPushSegue {
            segue.animated = true
            segue.replaceStrategy = .Stack
        }
    }

    // MARK: -
    
    @IBAction func didTapDone(sender: AnyObject) {
        self.vm.saveUsername()
            |> deliverOn(UIScheduler())
            |> onComplete { result in
                result.analysis(ifSuccess: {
                    self.performSegue(SegueIdentifier.Main_RootTab, sender: nil)
                }, ifFailure: { error in
                    let alert = UIAlertController(
                        title: error.title,
                        message: error.message,
                        preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true)
                })
        }
    }
}