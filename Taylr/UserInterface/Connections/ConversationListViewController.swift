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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarItem.title = nil
        layerClient = Layer.layerClient
        dataSource = self
        delegate = self
        displaysAvatarItem = false
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
        if let vc = segue.destinationViewController as? LayerConversationViewController {
            vc.layerClient = layerClient
            vc.conversation = selectedConversation
        }
    }
}

extension ConversationListViewController : ATLConversationListViewControllerDataSource {
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController!, titleForConversation conversation: LYRConversation!) -> String! {
        return "Test Conversation"
    }
}

extension ConversationListViewController : ATLConversationListViewControllerDelegate {
    
    func conversationListViewController(conversationListViewController: ATLConversationListViewController!, didSelectConversation conversation: LYRConversation!) {
        selectedConversation = conversation
        performSegue(.ConversationListToConversation)
    }
}