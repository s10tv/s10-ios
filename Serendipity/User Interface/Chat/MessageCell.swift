//
//  MessageCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/7/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

class MessageCell : UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var message : Message? {
        didSet {
            imageView.sd_setImageWithURL(message?.videoNSURL)
        }
    }
}
