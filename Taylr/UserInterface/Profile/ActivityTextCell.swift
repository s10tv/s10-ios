//
//  ActivityTextCell.swift
//  S10
//
//  Created by Tony Xiao on 6/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import Core

class ActivityTextCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var integrationNameLabel: UILabel!
    @IBOutlet weak var captionContainer: UIView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var captionToTextSpacing: NSLayoutConstraint!
    @IBOutlet weak var captionContainerHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
    }
    
    func bind(vm: ActivityTextViewModel) {
        usernameLabel.text = vm.displayName
        contentTextLabel.text = vm.text
        integrationNameLabel.text = vm.integrationName
        integrationNameLabel.textColor = vm.integrationColor
        avatarView.bindImage(vm.avatar)
        vm.displayTime ->> timestampLabel
        captionLabel.text = vm.caption
        if vm.caption != nil {
            captionToTextSpacing.constant = 24
            captionContainerHeight.active = false
        } else {
            captionToTextSpacing.constant = 0
            captionContainerHeight.constant = 0
            captionContainerHeight.active = true
        }
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        timestampLabel.designatedBond.unbindAll()
        avatarView.bindImage(nil)
    }
    
    static func reuseId() -> String {
        return reuseId(.ActivityTextCell)
    }
}