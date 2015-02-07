//
//  EditProfileViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import QuartzCore

@objc(EditProfileViewController)
class EditProfileViewController : BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var aboutField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutField.layer.cornerRadius = 15
        aboutField.layer.masksToBounds = true
    }
    
    
}
