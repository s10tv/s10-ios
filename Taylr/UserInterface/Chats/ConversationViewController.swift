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
import Bond

class ConversationViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var producer: ProducerViewController!
    var conversationVM: ConversationViewModel!
    var dataSourceBond: UICollectionViewDataSourceBond<UICollectionViewCell>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        producer = UIStoryboard(name: "AVKit", bundle: nil).instantiateInitialViewController() as! ProducerViewController
        producer.producerDelegate = self
        
        let messagesSection = conversationVM.messageViewModels.map { [unowned self] (message, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("MessageCell",
                forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! MessageCell
            cell.message = message
            cell.delegate = self
            return cell
        }
        let cameraSection = DynamicArray([producer]).map { [unowned self] (producer, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("ProducerCell",
                forIndexPath: NSIndexPath(forItem: index, inSection: 1)) as! ProducerCell
            self.addChildViewController(producer)
            cell.containerView.addSubview(producer.view)
            producer.view.makeEdgesEqualTo(cell.containerView)
            producer.didMoveToParentViewController(self)
            return cell
        }
        dataSourceBond = UICollectionViewDataSourceBond(collectionView: collectionView)
        DynamicArray([messagesSection, cameraSection]) ->> dataSourceBond
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = collectionView.bounds.size
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        avatarView.user = conversationVM.recipient
        conversationVM.recipient.displayName ->> nameLabel
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.user = conversationVM.recipient
        }
    }
}

extension ConversationViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MessageCell {
            cell.cellWillAppear()
            if let message = cell.message?.message {
                if message.statusEnum != .Opened && message.incoming {
                    // Async hack is needed otherwise collectionview gets into deadlock
                    dispatch_async(dispatch_get_main_queue()) {
                        Meteor.openMessage(message)
                    }
                }
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, didEndDisplayingCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MessageCell {
            cell.cellDidDisappear()
        }
    }
}

extension ConversationViewController : MessageCellDelegate {
    func messageCell(cell: MessageCell, didPlayMessage message: MessageViewModel) {
        if let indexPath = collectionView.indexPathForCell(cell) {
            let newPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
            collectionView.scrollToItemAtIndexPath(newPath, atScrollPosition: .CenteredVertically, animated: true)
        }
    }
}

extension ConversationViewController : ProducerDelegate {
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
        Log.info("I got a video \(url)")
        Globals.videoService.sendVideoMessage(conversationVM.recipient.connection()!,
            localVideoURL: url)
        PKHUD.hide(animated: false)
    }
}