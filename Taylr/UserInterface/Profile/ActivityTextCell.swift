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
    // Strong because otherwise it will be deallocated when inactive
    @IBOutlet var captionContainerHeight: NSLayoutConstraint!
    
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
        // MAJOR TODO: Figure out how to unbind then bind
        timestampLabel.text = vm.displayTime.value
//        vm.displayTime ->> timestampLabel.bnd_text
        captionLabel.text = vm.caption
        if vm.caption != nil {
            captionToTextSpacing.constant = 24
            captionContainerHeight.active = false
        } else {
            captionToTextSpacing.constant = 0
            captionContainerHeight.constant = 0
            captionContainerHeight.active = true
        }
        // http://stackoverflow.com/questions/30916163/uilabel-not-wrapping-reliably
        // https://app.asana.com/0/44915751562108/44316757241088
        // Hack to fix issue related to label not wrapping consistently
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
 
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.unbindImage()
    }
    
    static func reuseId() -> String {
        return reuseId(.ActivityTextCell)
    }
}