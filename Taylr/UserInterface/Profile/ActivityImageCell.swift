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
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var activity: ActivityViewModel? {
        didSet { if let a = activity { bindActivity(a) } }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.makeCircular()
        contentImageView.clipsToBounds = true
    }
    
    func bindActivity(activity: ActivityViewModel) {
//        activity.avatarURL ->> userImageView.dynImageURL
//        activity.username ->> usernameLabel
//        activity.formattedDate ->> timestampLabel
//        activity.text ->> contentTextLabel
//        activity.quote ->> quoteLabel
//        activity.serviceName ->> serviceNameLabel
//        activity.image.map { [unowned self] image in
//            if let image = image {
//                let width = self.contentImageView.frame.width
//                self.imageHeightConstraint.constant = width / image.width!.f * image.height!.f
//                return image.url
//            } else {
//                self.imageHeightConstraint.constant = 0
//                return nil
//            }
//        } ->> contentImageView.dynImageURL
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unbindAll(usernameLabel, timestampLabel, contentTextLabel, quoteLabel)
        [userImageView, contentImageView].each {
            $0.image = nil
            $0.unbindDynImageURL()
        }
    }
}