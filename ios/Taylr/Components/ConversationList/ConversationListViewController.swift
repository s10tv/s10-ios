
//  ConversationListViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import CocoaLumberjack
import ReactiveCocoa
import Atlas

class ConversationListViewController : ATLConversationListViewController {
    
    var selectedConversation: LYRConversation?
    var vm: ConversationListViewModel!
    
    override func viewDidLoad() {
        displaysAvatarItem = true
        shouldDisplaySearchController = false
        allowsEditing = false
        rowHeight = 86
        super.viewDidLoad()
        // TODO: Order in which we set this is important because setting
        // self.title also changes navigationItem.title
        title = nil
        navigationItem.title = "Connections"

        layerClient = vm.layerClient
        dataSource = vm
        delegate = self
        DDLogDebug("ConversationList - viewDidLoad")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DDLogDebug("ConversationList - viewWillAppear")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        DDLogDebug("ConversationList - viewDidAppear")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        DDLogDebug("ConversationList - viewWillDisappear")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        DDLogDebug("ConversationList - viewDidDisappear")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
            bottom: bottomLayoutGuide.length, right: 0)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if let vc = segue.destinationViewController as? ConversationViewController {
//            vc.vm = vm.conversationVM(selectedConversation!)
//        }
//    }
}

extension ConversationListViewController : ATLConversationListViewControllerDelegate {
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController!, didSelectConversation conversation: LYRConversation!) {
        selectedConversation = conversation
        print("Selected conversation id \(conversation.identifier.absoluteString)")
    }
}

// MARK: - ATLConversationListViewControllerDataSource

extension ConversationListViewModel : ATLConversationListViewControllerDataSource {
    class AvatarURLItem : NSObject, ATLAvatarItem {
        let avatarImageURL: NSURL
        let avatarImage: UIImage? = nil
        let avatarInitials: String? = nil
        
        init(_ url: NSURL) {
            avatarImageURL = url
        }
    }
    
    public func conversationListViewController(conversationListViewController: ATLConversationListViewController!, titleForConversation conversation: LYRConversation!) -> String!  {
        return displayNameForConversation(conversation)
    }
    
    public func conversationListViewController(conversationListViewController: ATLConversationListViewController!, avatarItemForConversation conversation: LYRConversation!) -> ATLAvatarItem! {
        return avatarForConversation(conversation).map { AvatarURLItem($0.url) }
    }
    
    public func conversationListViewController(conversationListViewController: ATLConversationListViewController!, lastMessageTextForConversation conversation: LYRConversation!) -> String! {
        return lastMessageTextForConversation(conversation)
    }
}
