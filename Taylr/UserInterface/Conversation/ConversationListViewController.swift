//
//  ConversationListViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/14/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Atlas
import Core

class ConversationListViewController : ATLConversationListViewController {
    
    var selectedConversation: LYRConversation?
    let vm = ConversationListViewModel(MainContext)
    
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
        
        layerClient = MainContext.layer.layerClient
        dataSource = vm
        delegate = self
        
        vm.changedConversations.observeOn(UIScheduler()).observeNext { [weak self] in
            Log.debug("Reloading conversation cell \($0)")
            self?.reloadCellForConversation($0)
        }
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
