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

protocol ActivityCellDelegate : class {
    func contentImageDidChange(cell: ActivityImageCell)
}

class ActivityImageCell : UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    
    var delegate: ActivityCellDelegate?
    var activity: ActivityViewModel? {
        didSet { if let a = activity { bindActivity(a) } }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.makeCircular()
        contentImageView.clipsToBounds = true
        contentImageView.racObserve("image").subscribeNext { [weak self] image in
            self?.delegate?.contentImageDidChange(self!)
        }
    }
    
    func bindActivity(activity: ActivityViewModel) {
//        activity.avatarURL ->> userImageView.dynImageURL
        activity.username ->> usernameLabel
        activity.formattedDate ->> timestampLabel
        activity.imageURL ->> contentImageView.dynImageURL
        activity.text ->> contentTextLabel
        activity.quote ->> quoteLabel
        activity.serviceName ->> serviceNameLabel
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