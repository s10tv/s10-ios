//
//  ConversationListViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import Atlas
import Core

class ConversationListViewController : ATLConversationListViewController {
    
    var selectedConversation: LYRConversation?
    let vm = ConversationListViewModel(MainContext)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Connections"
        tabBarItem.title = nil
        layerClient = MainContext.layer.layerClient
        dataSource = vm
        delegate = self
        displaysAvatarItem = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.contentInset = UIEdgeInsets(top: topLayoutGuide.length, left: 0,
            bottom: bottomLayoutGuide.length, right: 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationViewController {
            vc.layerClient = layerClient
            vc.vm = vm.conversationVM(selectedConversation!)
        }
    }
}

extension ConversationListViewController : ATLConversationListViewControllerDelegate {
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController!, didSelectConversation conversation: LYRConversation!) {
        selectedConversation = conversation
        performSegue(.ConversationListToConversation)
    }
}

// MARK: - ATLConversationListViewControllerDataSource

extension ConversationListViewModel : ATLConversationListViewControllerDataSource {
    public func conversationListViewController(conversationListViewController: ATLConversationListViewController!, titleForConversation conversation: LYRConversation!) -> String!  {
        return recipientForConversation(conversation).map { $0.displayName } ?? "..."
    }
    
    public func conversationListViewController(conversationListViewController: ATLConversationListViewController!, avatarItemForConversation conversation: LYRConversation!) -> ATLAvatarItem! {
        return recipientForConversation(conversation)
    }
}
