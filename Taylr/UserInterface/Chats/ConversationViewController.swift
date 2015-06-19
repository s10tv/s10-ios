//
//  ConversationViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import Core
import PKHUD

class ConversationViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var producer: ProducerViewController!
    var messagesVM: MessagesViewModel!
    var connection: Connection?
    var uploader: AzureUploader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        producer = UIStoryboard(name: "AVKit", bundle: nil).instantiateInitialViewController() as! ProducerViewController
        producer.producerDelegate = self
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
        return (messagesVM.frc.fetchedObjects?.count ?? 0) + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < messagesVM.frc.fetchedObjects?.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.message = messagesVM.frc.objectAtIndexPath(indexPath) as? Message
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProducerCell", forIndexPath: indexPath) as! ProducerCell
            addChildViewController(producer)
            cell.containerView.addSubview(producer.view)
            producer.view.makeEdgesEqualTo(cell.containerView)
            producer.didMoveToParentViewController(self)
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
//            if newPath.row < messagesVM.frc.fetchedObjects?.count {
                collectionView.scrollToItemAtIndexPath(newPath, atScrollPosition: UICollectionViewScrollPosition.CenteredVertically, animated: true)
//            }
        }
    }
}

extension ConversationViewController : ProducerDelegate {
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
        Log.info("I got a video \(url)")
        uploader = AzureUploader(meteorService: Meteor)
        uploader?.uploadFile(connection!.documentID!, localUrl: url)
        PKHUD.hide(animated: false)
    }
}