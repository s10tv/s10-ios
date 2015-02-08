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
    
    var viewModel = ArrayViewModel(content: [Photo]())
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        aboutField.layer.cornerRadius = 15
        aboutField.layer.masksToBounds = true
        
        // NOTE: Ideally this is more generic
        user = User.currentUser()
        
        aboutField.text = user?.about
        
        viewModel.bindToCollectionView(collectionView, cellNibName: "EditPhotoCell")
        viewModel.collectionViewProvider?.configureCollectionCell = { item, cell in
            (cell as EditPhotoCell).photo = (item as Photo)
        }
        if let photos = user?.photos {
            viewModel.content = photos
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        user?.beginWriting()
        user?.about = aboutField.text
        user?.endWriting()
    }
}
