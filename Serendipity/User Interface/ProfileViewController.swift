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

@objc(ProfileViewController)
class ProfileViewController : BaseViewController, SwipeViewDelegate, SwipeViewDataSource {

    @IBOutlet weak var swipeView: SwipeView!
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = User.MR_findFirst()
        swipeView.reloadData()
    }
    
    func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
        return user?.photos != nil ? (user?.photos?.count)! : 0
    }
    
    func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
        let v = view != nil ? view as UIImageView : UIImageView()
        let url = (user?.photos as [Photo])[index].url
        v.sd_setImageWithURL(NSURL(string: url))
        return v
    }
    
    func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
        return swipeView.frame.size
    }
    
}