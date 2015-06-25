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
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nameCenterConstraint: NSLayoutConstraint!
    
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
            cell.containerView.addSubview(producer.view)
            producer.view.makeEdgesEqualTo(cell.containerView)
            // NOTE: For some reason we have to call addChildViewController AFTER adding view
            // otherwise the recorder view doesn't show up until later, also manually calling
            // viewWillAppear here
            self.addChildViewController(producer)
            producer.viewWillAppear(false)
            producer.didMoveToParentViewController(self)
            return cell
        }
        dataSourceBond = UICollectionViewDataSourceBond(collectionView: collectionView)
        DynamicArray([messagesSection, cameraSection]) ->> dataSourceBond
        
        avatarView.user = conversationVM.recipient.value!
        conversationVM.recipient.value!.displayName ->> nameLabel
        conversationVM.hasUnsentMessage ->> spinner
        conversationVM.formattedStatus ->> activityLabel
        conversationVM.badgeText ->> badgeLabel
        conversationVM.formattedStatus.map { $0.length == 0 } ->> nameCenterConstraint.dynActive
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = collectionView.bounds.size
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.user = conversationVM.recipient.value!
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
            var newPath: NSIndexPath!
            if indexPath.row < collectionView.numberOfItemsInSection(indexPath.section) - 1 {
                newPath = NSIndexPath(forItem: indexPath.row + 1, inSection: indexPath.section)
            } else {
                newPath = NSIndexPath(forItem: 0, inSection: indexPath.section + 1)
            }
            collectionView.scrollToItemAtIndexPath(newPath, atScrollPosition: .CenteredVertically, animated: true)
        }
    }
}

extension ConversationViewController : ProducerDelegate {
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
        Log.info("I got a video \(url)")
        Globals.videoService.sendVideoMessage(conversationVM.connection,
            localVideoURL: url)
        PKHUD.hide(animated: false)
    }
}