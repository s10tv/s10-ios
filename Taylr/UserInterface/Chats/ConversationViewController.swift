//
//  ConversationViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation

class ConversationViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var messagesVM: MessagesViewModel!
    var connection: Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesVM = MessagesViewModel(connection: connection!, delegate: nil)
        messagesVM.bindCollectionView(collectionView)
        messagesVM.loadMessages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = collectionView.bounds.size
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        
        avatarView.user = connection?.otherUser
        nameLabel.text = connection?.otherUser?.displayName
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
}