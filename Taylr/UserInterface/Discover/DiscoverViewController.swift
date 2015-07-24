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
    
    var discoverVM : DiscoverInteractor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(inset: 10)
        collectionView.collectionViewLayout = layout

        discoverVM = DiscoverInteractor()
        discoverVM.candidates.map { [unowned self] (vm, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.CandidateCell,
                forIndexPath: NSIndexPath(forItem: index, inSection: 0)) as! CandidateCell
            cell.bindViewModel(vm)
            return cell
        } ->> collectionView
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
            let user = discoverVM.candidates[indexPath.row].user
            profileVC.profileVM = ProfileInteractor(meteor: Meteor, user: user)
        }
    }
}

extension DiscoverViewController : CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        if let avatar = discoverVM.candidates[indexPath.item].avatar.value,
            let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout {
                // TODO: Consider using prototype cell for this
                let rowWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
                let itemWidth = (rowWidth - (layout.columnCount.f - 1) * layout.minimumColumnSpacing) / layout.columnCount.f
                let imageHeight = (avatar.height!.f / avatar.width!.f) * itemWidth
                // 79 is magic number for distance between bottom of avatar image view and bottom of cell
                let itemHeight = imageHeight + 79
            return CGSize(width: itemWidth, height: itemHeight)
        }
        Log.error("Returning default layout size 50x80, avatar likely missing")
        return CGSize(width: 50, height: 80)
    }
}