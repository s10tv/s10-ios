//
//  ProfileInfoCell.swift
//  Ketch
//
//  Created by Tony Xiao on 3/30/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

class ProfileInfoCell : UICollectionViewCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    var item : ProfileInfoItem? {
        didSet {
            iconView.image = item?.image?.imageWithRenderingMode(.AlwaysTemplate)
            textLabel.text = item?.text
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.tintColor = StyleKit.navy
    }
    
    class func sizeForItem(item: ProfileInfoItem) -> CGSize {
        struct Static {
            static let SizingCell = UINib(nibName: "ProfileInfoCell", bundle: nil).instantiateWithOwner(nil, options: nil).first as! ProfileInfoCell
        }
        Static.SizingCell.item = item
        Static.SizingCell.setNeedsLayout()
        Static.SizingCell.layoutIfNeeded()
        return Static.SizingCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
    }
}