//
//  ConversationViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import Core

class ConversationViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var recorder: RecorderViewController!
    var messagesVM: MessagesViewModel!
    var connection: Connection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
//        recorder = makeViewController(.Recorder) as! RecorderViewController
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

extension ConversationViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (messagesVM.frc.fetchedObjects?.count ?? 0) //+ 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < messagesVM.frc.fetchedObjects?.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.message = messagesVM.frc.objectAtIndexPath(indexPath) as? Message
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RecorderCell", forIndexPath: indexPath) as! UICollectionViewCell
            addChildViewController(recorder)
            cell.addSubview(recorder.view)
            recorder.view.makeEdgesEqualTo(cell)
            recorder.didMoveToParentViewController(self)
            return cell
        }
    }
}

extension ConversationViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MessageCell {
            cell.player.play()
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MessageCell {
            cell.player.pause()
        }
    }
}

extension ConversationViewController : MessageCellDelegate {
    func messageCell(cell: MessageCell, didPlayMessage message: Message) {
        if let indexPath = messagesVM.frc.indexPathForObject(message) {
            let newPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            if newPath.row < messagesVM.frc.fetchedObjects?.count {
                collectionView.scrollToItemAtIndexPath(newPath, atScrollPosition: UICollectionViewScrollPosition.CenteredHorizontally, animated: true)
            }
        }
    }
}