//
//  LayerConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Atlas
import Core

class LayerConversationViewController : ATLConversationViewController {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var vm: LayerConversationViewModel! {
        didSet { conversation = vm.conversation }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = vm
        
        let backgroundImageView = UIImageView()
        backgroundImageView.contentMode = .ScaleAspectFill
        backgroundImageView.clipsToBounds = true
        view.insertSubview(backgroundImageView, atIndex: 0)
        backgroundImageView.makeEdgesEqualTo(view)
        
        avatarView.sd_image <~ vm.avatar
        titleLabel.rac_text <~ vm.displayName
        statusLabel.rac_text <~ vm.displayStatus
        backgroundImageView.sd_image <~ vm.cover
    }
    
    
    @IBAction func didTapBackButton(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
}

// MARK: - ATLConversationViewControllerDataSource

extension LayerConversationViewModel : ATLConversationViewControllerDataSource {
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, participantForIdentifier participantIdentifier: String!) -> ATLParticipant! {
        return recipient()
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfDate date: NSDate!) -> NSAttributedString! {
        return NSAttributedString(string: "Date")
    }
    
    public func conversationViewController(conversationViewController: ATLConversationViewController!, attributedStringForDisplayOfRecipientStatus recipientStatus: [NSObject : AnyObject]!) -> NSAttributedString! {
        return NSAttributedString(string: "Status")
    }
    
}

