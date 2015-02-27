//
//  EditPhotoCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/6/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class EditPhotoCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photo : Photo? {
        didSet {
            if let url = photo?.url {
                imageView.sd_setImageWithURL(NSURL(string: url))
            }
        }
    }
    
    @IBAction func remove(sender: AnyObject) {
        println("Want to remove photo \(photo?.url)")
    }
}
