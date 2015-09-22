//
//  HistoryViewController.swift
//  S10
//
//  Created by Tony Xiao on 9/22/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import CHTCollectionViewWaterfallLayout
import DZNEmptyDataSet
import Core

class HistoryViewController : BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    let vm = HistoryViewModel(meteor: Meteor, taskService: Globals.taskService)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(inset: 10)
        collectionView.collectionViewLayout = layout
            
        vm.candidates.map(collectionView.factory(HistoryCandidateCell)) ->> collectionView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 66, left: 0, // HACK ALERT: Hard-coded
            bottom: bottomLayoutGuide.length, right: 0)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController,
            let indexPath = collectionView.indexPathsForSelectedItems().first as? NSIndexPath {
            profileVC.vm = vm.profileVM(indexPath.row)
        }
    }
    
}

extension HistoryViewController : CHTCollectionViewDelegateWaterfallLayout {
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        if let avatar = vm.candidates[indexPath.item].avatar,
            let layout = collectionViewLayout as? CHTCollectionViewWaterfallLayout {
                // TODO: Consider using prototype cell for this
                let rowWidth = collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right
                let itemWidth = (rowWidth - (layout.columnCount.f - 1) * layout.minimumColumnSpacing) / layout.columnCount.f
                let imageHeight = ((avatar.height ?? 100).f / (avatar.width ?? 100).f) * itemWidth
                // TODO: take into account height of the tagline
                // 79 is magic number for distance between bottom of avatar image view and bottom of cell
                // 33 is the magic number for top of the card to top of the cell
                let itemHeight = imageHeight + 79 + 33
            return CGSize(width: itemWidth, height: itemHeight)
        }
        Log.error("Returning default layout size 50x80, avatar likely missing")
        return CGSize(width: 50, height: 80)
    }
}
