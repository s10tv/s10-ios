//
//  ProfileSelectorRowCell.swift
//  S10
//
//  Created by Tony Xiao on 7/24/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Bond
import Core

class ProfileSelectorRowCell : UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!

    func bind(profiles: DynamicArray<UserViewModel.Profile>) {
        profiles.map { [unowned self] (profile, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.ProfileSelectorCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ProfileSelectorCell
            cell.bind(profile)
            return cell
        } ->> collectionView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fatalError("ProfileCoverCell is not designed to be re-used")
    }
}