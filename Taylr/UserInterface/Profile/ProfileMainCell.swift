//
//  ProfileMainCell.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import Bond

class ProfileMainCell : UITableViewCell {
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avatarView: UserAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func bindViewModel(viewModel: ProfileInteractor) {
        viewModel.avatarURL ->> avatarView.dynImageURL
        viewModel.coverURL ->> coverImageView.dynImageURL
        viewModel.displayName ->> nameLabel
        viewModel.username ->> usernameLabel
        viewModel.distance ->> distanceLabel
        viewModel.lastActive ->> activityLabel
        viewModel.about ->> aboutLabel
        viewModel.services.map { [unowned self] (service, index) -> UICollectionViewCell in
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier(.ServiceCell,
                forIndexPath: NSIndexPath(forRow: index, inSection: 0)) as! ProfileServiceCell
            cell.service = service
            return cell
        } ->> collectionView
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        fatalError("ProfileMainCell is not designed to be re-used")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.clipsToBounds = true
        avatarView.dynPlaceholderImage = avatarView.image
        coverImageView.dynPlaceholderImage = coverImageView.image
    }
}