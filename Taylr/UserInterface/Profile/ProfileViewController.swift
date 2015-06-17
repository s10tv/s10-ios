//
//  ProfileViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/27/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SwipeView
import SDWebImage
import Cartography
import Core

class ProfileViewController : BaseViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoCollection: UICollectionView!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    
    var infoItems = ArrayViewModel(content: [ProfileInfoItem]())
    
    var user : User!
    
    override func commonInit() {
        screenName = "Profile"
    }
    
    override func viewDidLoad() {
        assert(user != nil, "Must set user before attempt to loading ProfileVC")
        super.viewDidLoad()
        
        // TODO: Find better solution than hardcoding keypath string
        RAC(nameLabel, "text") <~ user.racObserve("displayName")
        RAC(aboutLabel, "rawText") <~ user.racObserve("about")

        infoItems.bindToCollectionView(infoCollection, cellNibName: "ProfileInfoCell")
        infoItems.collectionViewProvider?.configureCollectionCell = { item, cell in
            (cell as! ProfileInfoCell).item = (item as! ProfileInfoItem)
        }
        infoCollection.delegate = self
        (view as! UIScrollView).delegate = self
        swipeView.clipsToBounds = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        infoItems.content = user.infoItems ?? []
        swipeView.reloadData()
        swipeView.scrollToItemAtIndex(0, duration: 0)
        infoCollection.reloadData()
        // Right now the only thing more button does is report user
        // therefore the best way to hide this ability is to hide more button
        moreButton.hidden = user.isCurrentUser
    }
    
    override func updateViewConstraints() {
        constrain(backButton, moreButton, view.superview!) { backButton, moreButton, superview in
            backButton.top == superview.top
            moreButton.top == superview.top
        }
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        // Automatic preferredMaxLayoutWidth does not seem to work
        // when label is laid out relative to scroll view contentSize
        aboutLabel.preferredMaxLayoutWidth = aboutLabel.frame.width
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Action
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(.moreSheetReport, user!.firstName!), style: .Destructive) { _ in
            self.reportUser(sender)
        }
        sheet.addAction(LS(.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(.reportAlertTitle), message: LS(.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
                Meteor.reportUser(self.user, reason: reportReason)
            }
        }
        presentViewController(alert)
    }
}

// MARK: Collection View Delegate

extension ProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = infoItems.itemAtIndexPath(indexPath) as! ProfileInfoItem
        var size = ProfileInfoCell.sizeForItem(item)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        size.width = between(layout.maxItemWidth * item.minWidthRatio, size.width, layout.maxItemWidth)
        return size
    }

}

// MARK: ScrollView Delegate

extension ProfileViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        if (yOffset < 0) {
            let imageView = swipeView.currentItemView
            var frame = imageView.frame
            frame.origin.y = yOffset
            frame.size.height = scrollView.frame.width + -yOffset
            imageView.frame = frame
        }
    }
}

// MARK: - Showing multiple users horizontally paged

extension ProfileViewController {
    class func pagedController(users: [User], initialPage: Int = 0, factory: () -> ProfileViewController) -> PageViewController {
        assert(initialPage >= 0 && initialPage < users.count, "Initial page range invalid")
        let pageVC = PageViewController()
        pageVC.viewControllers = map(users) {
            let profileVC = factory()
            profileVC.user = $0
            return profileVC
        }
        pageVC.scrollTo(page: initialPage, animated: false)
        return pageVC
    }
}
