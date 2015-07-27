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

class ActivityImageCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.makeCircular()
        contentImageView.clipsToBounds = true
    }
    
    func bind(vm: ActivityImageViewModel) {
        usernameLabel.text = vm.displayName
        contentTextLabel.text = vm.text
        serviceNameLabel.text = vm.integrationName
        serviceNameLabel.textColor = vm.integrationColor
        userImageView.bindImage(vm.avatar)
        contentImageView.bindImage(vm.image)
        vm.displayTime ->> timestampLabel
//        imageHeightConstraint.constant = CGFloat(vm.image.height ?? 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timestampLabel.designatedBond.unbindAll()
        [userImageView, contentImageView].each {
            $0.bindImage(nil)
        }
    }
    
    static func reuseId() -> String {
        return reuseId(.ActivityImageCell)
    }
    
}