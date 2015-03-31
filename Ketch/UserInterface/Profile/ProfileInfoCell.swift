//
//  ProfileInfoCell.swift
//  Ketch
//
//  Created by Tony Xiao on 3/30/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class ProfileInfoItem {
    enum ItemType {
        case Location, Age, Height, Work, Education
    }
    let type : ItemType
    let text : String
    let imageName : String
    let minWidthRatio : CGFloat = 0
    
    var image : UIImage! {
        return UIImage(named: imageName)
    }
    
    init(type: ItemType, text: String) {
        self.type = type
        self.text = text
        switch type {
        case .Location:
            imageName = R.ImagesAssets.settingsLocation
        case .Age:
            imageName = R.ImagesAssets.settingsAge
        case .Height:
            imageName = R.ImagesAssets.settingsHeightArrow
        case .Work:
            imageName = R.ImagesAssets.settingsBriefcase
            minWidthRatio = 1
        case .Education:
            imageName = R.ImagesAssets.settingsMortarBoard
            minWidthRatio = 1
        }
    }
}

class ProfileInfoCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var item : ProfileInfoItem? {
        didSet {
            iconView.image = item?.image
            textLabel.text = item?.text
        }
    }
    
    class func sizeForItem(item: ProfileInfoItem) -> CGSize {
        struct Static {
            static let SizingCell = UINib(nibName: "ProfileInfoCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as ProfileInfoCell
        }
        Static.SizingCell.item = item
        Static.SizingCell.setNeedsLayout()
        Static.SizingCell.layoutIfNeeded()
        return Static.SizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
}