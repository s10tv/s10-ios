//
//  CandidateServiceCell.swift
//  S10
//
//  Created by Tony Xiao on 7/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import Core

class ProfileIconCell : UICollectionViewCell, BindableCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func bind(vm: Image) {
        imageView.sd_image.value = vm
    }
    
    static func reuseId() -> String {
        return reuseId(.ProfileIconCell)
    }
}