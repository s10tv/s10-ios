//
//  InviteViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import JVFloatLabeledTextField
import PKHUD
import Core

class InviteViewController : UIViewController {
    
    @IBOutlet weak var firstNameField: JVFloatLabeledTextField!
    @IBOutlet weak var lastNameField: JVFloatLabeledTextField!
    @IBOutlet weak var emailOrPhoneField: JVFloatLabeledTextField!
    
    let vm = InviteViewModel(meteor: Meteor, taskService: Globals.taskService)

    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameField.rac_text <<~> vm.firstName
        lastNameField.rac_text <<~> vm.lastName
        emailOrPhoneField.rac_text <<~> vm.emailOrPhone
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
    }
    
    func producer(producer: ProducerViewController, didProduceVideo video: VideoSession, duration: NSTimeInterval) {
        producer.dismissViewController(animated: true)
        wrapFuture(showProgress: true) {
            video.exportWithFirstFrame()
                .flatMap { self.vm.sendInvite($0, thumbnail: $1) }
        }
    }
}