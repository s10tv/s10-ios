//
//  PermissionViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/3/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

@objc(PermissionViewController)
class PermissionViewController : BaseViewController {
    
    var permissionType : PermissionType!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var explanationLabel: DesignableLabel!
    @IBOutlet weak var mainButton: DesignableButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = permissionType.image
        explanationLabel.rawText = permissionType.explanation
        mainButton.text = permissionType.buttonTitle
    }
    
}