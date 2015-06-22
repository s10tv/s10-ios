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
    var vm: ConversationViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        producer = UIStoryboard(name: "AVKit", bundle: nil).instantiateInitialViewController() as! ProducerViewController
        producer.producerDelegate = self
        vm.didReload = { [weak self] _ in
            self?.collectionView.reloadData()
            return
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = collectionView.bounds.size
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = true
        vm.reloadData()
        avatarView.user = vm.recipient
        nameLabel.text = vm.recipient.displayName
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBarHidden = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ProfileViewController {
            vc.user = vm.recipient
        }
    }
}

extension ConversationViewController : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.messageVMs.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row < vm.messageVMs.count {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
            cell.message = vm.messageVMs[indexPath.row]
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
        if let index = vm.indexOfMessage(message) {
            let newPath = NSIndexPath(forRow: index + 1, inSection: 0)
            collectionView.scrollToItemAtIndexPath(newPath, atScrollPosition: .CenteredVertically, animated: true)
        }
    }
}

extension ConversationViewController : ProducerDelegate {
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
        Log.info("I got a video \(url)")
        Globals.videoService.sendVideoMessage(vm.recipient.connection()!,
            localVideoURL: url)
        PKHUD.hide(animated: false)
    }
}