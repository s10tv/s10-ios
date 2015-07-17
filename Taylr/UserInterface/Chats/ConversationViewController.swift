//
//  ConversationViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/14/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import ReactiveCocoa
import PKHUD
import Bond
import Core

class ConversationViewController : BaseViewController {
    
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var badgeLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var nameCenterConstraint: NSLayoutConstraint!
    
    var producer: ProducerViewController!
    var conversationVM: ConversationInteractor!
    var dataBond: Bond<[MessageViewModel]>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        producer = UIStoryboard(name: "AVKit", bundle: nil).instantiateInitialViewController() as! ProducerViewController
        producer.producerDelegate = self
        
        dataBond = Bond { [weak self] x in
            if let stateProducer = self?.conversationVM.state.producer {
                stateProducer
                    |> filter { $0 == .Idle }
                    |> take(1)
                    |> start(completed: { [weak self] in
                        Log.info("Reloading messages count: \(x.count)")
                        self?.collectionView.reloadData()
                    })
            }
        }
        conversationVM.reloadMessages()
        avatarView.user = conversationVM.recipient
        conversationVM.recipient.displayName ->> nameLabel
        conversationVM.busy ->> spinner
        conversationVM.formattedStatus ->> activityLabel
        conversationVM.badgeText ->> badgeLabel
        conversationVM.formattedStatus.map { $0.length == 0 } ->> nameCenterConstraint.dynActive
        conversationVM.messageViewModels ->> dataBond
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
            vc.profileVM = ProfileInteractor(meteor: Meteor, user: conversationVM.recipient)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.moreSheetBlock, conversationVM.recipient.firstName!), style: .Destructive) { _ in
            self.blockUser(sender)
        }
        sheet.addAction(LS(.moreSheetReport, conversationVM.recipient.firstName!), style: .Destructive) { _ in
            self.reportUser(sender)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func blockUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            Meteor.blockUser(self.conversationVM.recipient)
        }
        presentViewController(alert)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
                Meteor.reportUser(self.conversationVM.recipient, reason: reportReason)
            }
        }
        presentViewController(alert)
    }
    
}

private enum Sections : Int {
    case Messages = 0
    case Camera = 1
}

extension ConversationViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == Sections.Camera.rawValue ? 1 : conversationVM.messageViewModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == Sections.Camera.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(.ProducerCell,
                forIndexPath: indexPath) as! ProducerCell
            cell.containerView.addSubview(producer.view)
            producer.view.makeEdgesEqualTo(cell.containerView)
            // NOTE: For some reason we have to call addChildViewController AFTER adding view
            // otherwise the recorder view doesn't show up until later, also manually calling
            // viewWillAppear here
            self.addChildViewController(producer)
            producer.viewWillAppear(false)
            producer.didMoveToParentViewController(self)
            return cell
        } else {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.MessageCell,
                forIndexPath: indexPath) as! MessageCell
            cell.message = conversationVM.messageViewModels[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
}

extension ConversationViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? MessageCell {
            cell.cellWillAppear()
            conversationVM.playing.value = true
            // TODO: Get a better idea on the lifecycle
            println("Will display cell \(indexPath)")
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
            println("did stop playing cell \(indexPath)")
            conversationVM.playing.value = false
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
    
    func producerWillStartRecording(producer: ProducerViewController) {
        conversationVM.recording.value = true
    }
    
    func producerDidCancelRecording(producer: ProducerViewController) {
        conversationVM.recording.value = false
    }
    
    func producer(producer: ProducerViewController, didProduceVideo url: NSURL) {
        conversationVM.recording.value = false
        Log.info("I got a video \(url)")
        Globals.taskService.uploadVideo(conversationVM.recipient, localVideoURL: url)
        PKHUD.hide(animated: false)
    }
}