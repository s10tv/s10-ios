//
//  DiscoverViewController.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core
import CHTCollectionViewWaterfallLayout
import Bond

class DiscoverViewController : BaseViewController {
    
    @IBOutlet weak var collectionView : UICollectionView!
    
    let vm = DiscoverViewModel(meteor: Meteor)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(inset: 10)
        collectionView.collectionViewLayout = layout

        vm.candidates.map(collectionView.factory(CandidateCell)) ->> collectionView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBarHidden = false
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
        Globals.locationService.requestPermission()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 66, left: 0, // HARCK ALERT: Hard-coded
                                                bottom: bottomLayoutGuide.length, right: 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController,
            let indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath {
            profileVC.vm = vm.profileVM(indexPath.row)
        }
    }
}

extension DiscoverViewController : CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        if let avatar = vm.candidates[indexPath.item].avatar,
            let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout {
                // TODO: Consider using prototype cell for this
                let rowWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
                let itemWidth = (rowWidth - (layout.columnCount.f - 1) * layout.minimumColumnSpacing) / layout.columnCount.f
                let imageHeight = ((avatar.height ?? 100).f / (avatar.width ?? 100).f) * itemWidth
                // 79 is magic number for distance between bottom of avatar image view and bottom of cell
                let itemHeight = imageHeight + 79
            return CGSize(width: itemWidth, height: itemHeight)
        }
        Log.error("Returning default layout size 50x80, avatar likely missing")
        return CGSize(width: 50, height: 80)
    }
}