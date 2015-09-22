//
//  DiscoverViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import CHTCollectionViewWaterfallLayout
import AMScrollingNavbar
import DZNEmptyDataSet
import Core

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    let vm = DiscoverViewModel(meteor: Meteor, taskService: Globals.taskService)
    let emptyDataBond = ArrayBond<CurrentCandidateViewModel>()
    
    deinit {
        collectionView?.delegate = nil
        collectionView?.emptyDataSetSource = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.emptyDataSetSource = self
        
//        let layout = CHTCollectionViewWaterfallLayout()
//        layout.minimumColumnSpacing = 10
//        layout.minimumInteritemSpacing = 10
//        layout.sectionInset = UIEdgeInsets(inset: 10)
//        collectionView.collectionViewLayout = layout
//        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        
        vm.candidate.map(collectionView.factory(CandidateCell)) ->> collectionView
        vm.candidate.bindTo(emptyDataBond)
        emptyDataBond.didPerformBatchUpdatesListener = { [weak self] in
            self?.collectionView.reloadEmptyDataSet()
        }
        
        listenForNotification(DidTouchStatusBar).start(next: { [weak self] _ in
            self?.showNavBarAnimated(true)
            self?.collectionView.scrollToTop(animated: true)
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
//        followScrollView(collectionView, usingTopConstraint: topLayoutConstraint, withDelay: 50)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: Temporarily request all access to all permissions
        let settings = UIUserNotificationSettings(forTypes:
            UIUserNotificationType.Badge |
                UIUserNotificationType.Alert |
                UIUserNotificationType.Sound,
            categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        Globals.analyticsService.screen("Discover")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        showNavBarAnimated(false)
//        stopFollowingScrollView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 66, left: 0, // HARCK ALERT: Hard-coded
                                                bottom: bottomLayoutGuide.length, right: 0)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        var itemSize = collectionView.bounds.size
        itemSize.width -= 20 // 10 on each side
        itemSize.height -= (topLayoutGuide.length + bottomLayoutGuide.length + 20) // 10 on each side
        layout.itemSize = itemSize
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController,
            let profileVM = vm.profileVM() {
            profileVC.vm = profileVM
        }
        if let vc = segue.destinationViewController as? ConversationViewController,
            let conversationVM = vm.conversationVM() {
            vc.vm = conversationVM
        }
    }
}

//extension DiscoverViewController : CHTCollectionViewDelegateWaterfallLayout {
//    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
//        if let avatar = vm.candidates[indexPath.item].avatar,
//            let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout {
//                // TODO: Consider using prototype cell for this
//                let rowWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
//                let itemWidth = (rowWidth - (layout.columnCount.f - 1) * layout.minimumColumnSpacing) / layout.columnCount.f
//                let imageHeight = ((avatar.height ?? 100).f / (avatar.width ?? 100).f) * itemWidth
//                // TODO: take into account height of the tagline
//                // 79 is magic number for distance between bottom of avatar image view and bottom of cell
//                let itemHeight = imageHeight + 79
//            return CGSize(width: itemWidth, height: itemHeight)
//        }
//        Log.error("Returning default layout size 50x80, avatar likely missing")
//        return CGSize(width: 50, height: 80)
//    }

//extension DiscoverViewController : UIScrollViewDelegate {
//    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        println("Scrolling to y = \(targetContentOffset.memory.y)")
//        if targetContentOffset.memory.y < 600 {
////            setContentOffset(CGPointMake(0, -contentInset.top), animated: animated)
//            targetContentOffset.memory.y = -scrollView.contentInset.top
////            scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.contentInset.top), animated: true)
//        }
//    }
//}

extension DiscoverViewController : DZNEmptyDataSetSource {
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: LS(.emptyDiscoverMessage), attributes: [
            NSFontAttributeName: UIFont(.cabinRegular, size: 20)
        ])
    }
}
