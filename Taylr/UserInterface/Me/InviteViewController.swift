//
//  InviteViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import JVFloatLabeledTextField
import ReactiveCocoa
import Bond
import Core
import PKHUD

class InviteViewController : UIViewController {
    
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var emailOrPhoneField: JVFloatLabeledTextField!
    
    let vm = InviteViewModel(meteor: Meteor, taskService: Globals.taskService)

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.firstName <->> firstNameField
        vm.lastName <->> lastNameField
        vm.emailOrPhone <->> emailOrPhoneField
    }
    
    @IBAction func didPressSend(sender: AnyObject) {
        if let error = vm.validateInvite() {
            presentError(error)
        } else {
            let producer = UIStoryboard(name: "AVKit", bundle: nil).instantiateInitialViewController() as! ProducerViewController
            producer.title = "Invite \(vm.firstName.value)"
            producer.producerDelegate = self
            presentViewController(producer, animated: true)
        }
    }
    
}
extension InviteViewController : ProducerDelegate {
    func producerWillStartRecording(producer: ProducerViewController) {
    }
    
    func producerDidCancelRecording(producer: ProducerViewController) {
        producer.dismissViewController(animated: true)
    }
    
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
        producer.dismissViewController(animated: true)
        vm.sendInvite(url)
            |> deliverOn(UIScheduler())
            |> onSuccess {
                PKHUD.showText("Sent Successfully!")
                PKHUD.hide(afterDelay: 0.25)
            }
            |> onFailure { error in
                PKHUD.hide(animated: false)
                self.showErrorAlert(error)
            }
    }
}