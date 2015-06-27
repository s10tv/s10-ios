//
//  ProfileImageCell.swift
//  S10
//
//  Created by Tony Xiao on 6/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core

class ProfileImageCell : UITableViewCell {
    
    @IBOutlet weak var serviceIconView: UIImageView!
    @IBOutlet weak var activityImageView: UIImageView!
    
    var activity: Activity?
}