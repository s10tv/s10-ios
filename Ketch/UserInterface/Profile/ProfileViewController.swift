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

@objc(ProfileViewController)
class ProfileViewController : BaseViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var swipeView: SwipeView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoCollection: UICollectionView!
    @IBOutlet weak var aboutLabel: DesignableLabel!
    
    var infoItems = ArrayViewModel(content: [ProfileInfoItem]())
    
    var user : User? {
        willSet {
            willChangeValueForKey("user")
        }
        didSet {
            didChangeValueForKey("user")
            if isViewLoaded() { reloadData() }
        }
    }
    
    convenience init(user: User) {
        self.init()
        self.user = user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Find better solution than hardcoding keypath string
        RAC(nameLabel, "text") <~ racObserve("user.displayName")
        RAC(aboutLabel, "rawText") <~ racObserve("user.about")

        infoItems.bindToCollectionView(infoCollection, cellNibName: "ProfileInfoCell")
        infoItems.collectionViewProvider?.configureCollectionCell = { item, cell in
            (cell as ProfileInfoCell).item = (item as ProfileInfoItem)
        }
        infoCollection.delegate = self
        (view as UIScrollView).delegate = self
        swipeView.clipsToBounds = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
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
    
    @IBAction func goBack(sender: AnyObject) {
        dismissViewController()
    }
    
    @IBAction func showMoreOptions(sender: AnyObject) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        sheet.addAction(LS(R.Strings.moreSheetReport, user!.firstName!), style: .Destructive) { _ in
            self.reportUser(sender)
        }
        sheet.addAction(LS(R.Strings.moreSheetCancel), style: .Cancel)
        presentViewController(sheet)
    }
    
    @IBAction func reportUser(sender: AnyObject) {
        let alert = UIAlertController(title: LS(R.Strings.reportAlertTitle), message: LS(R.Strings.reportAlertMessage), preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler(nil)
        alert.addAction(LS(R.Strings.reportAlertCancel), style: .Cancel)
        alert.addAction(LS(R.Strings.reportAlertConfirm), style: .Destructive) { _ in
            if let reportReason = (alert.textFields?[0] as? UITextField)?.text {
                Core.meteor.callMethod("user/report", params: [self.user!.documentID!, reportReason])
            }
        }
        presentViewController(alert)
    }
    
    func reloadData() {
        infoItems.content = user?.infoItems ?? []
        swipeView.reloadData()
        swipeView.scrollToItemAtIndex(0, duration: 0)
        pageControl.numberOfPages = numberOfItemsInSwipeView(swipeView)
        infoCollection.reloadData()
    }
}

// MARK: - Photos SwipeView Delegate / Data Source

extension ProfileViewController : SwipeViewDataSource {
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return user?.photos != nil ? (user?.photos?.count)! : 0
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let v = view != nil ? view as UIImageView : UIImageView()
        v.contentMode = .ScaleAspectFill
        let url = user?.photos![index].url
        v.sd_setImageWithURL(NSURL(string: url!))
        return v
    }
}

extension ProfileViewController : SwipeViewDelegate {
    func swipeViewCurrentItemIndexDidChange(swipeView: SwipeView!) {
        pageControl.currentPage = swipeView.currentPage
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return swipeView.frame.size
    }
}

// MARK: Collection View Delegate

extension ProfileViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewFlowLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let item = infoItems.itemAtIndexPath(indexPath) as ProfileInfoItem
        var size = ProfileInfoCell.sizeForItem(item)
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