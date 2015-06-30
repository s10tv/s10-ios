//
//  ActivityImageCell.swift
//  S10
//
//  Created by Tony Xiao on 6/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import Bond

class ActivityImageCell : UITableViewCell {
    
    @IBOutlet weak var serviceIconView: UIImageView!
    @IBOutlet weak var activityImageView: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var actionLabel: UILabel!
    
    var activity: ActivityViewModel? {
        didSet { if let a = activity { bindActivity(a) } }
    }
    
    func bindActivity(activity: ActivityViewModel) {
        activity.imageURL ->> activityImageView.dynImageURL
        activity.serviceIcon ->> serviceIconView
        activity.formattedDate ->> timestampLabel
        activity.formattedAction ->> actionLabel
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unbindAll(timestampLabel, actionLabel)
        serviceIconView.designatedBond.unbindAll()
        activityImageView.unbindDynImageURL()
    }
}