//
//  EditHashtagsViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/9/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

class EditHashtagsViewController : UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    var vm: EditHashtagsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = EditHashtagsViewModel(meteor: Meteor)
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSizeMake(80, 35)
        

        collectionView <~ (vm.hashtags, HashtagCell.self)
    }
}

extension EditHashtagsViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        vm.toggleHashtagAtIndex(indexPath.item)
    }
}

// MARK: - 

// TODO: Eventually use self-sizing UICollectionViewCell instead of hardcoding like this...

private let HashtagFont = UIFont(.cabinRegular, size: 14)

extension EditHashtagsViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let hashtag = vm.hashtags.array[indexPath.item]
        var size = (hashtag.displayText as NSString).boundingRectWithSize(CGSizeMake(1000, 1000),
            options: [], attributes: [NSFontAttributeName: HashtagFont], context: nil).size
        size.width += 8 * 2
        size.height += 8 * 2
        return size
    }
}