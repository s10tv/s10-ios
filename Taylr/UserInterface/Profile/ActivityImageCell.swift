//
//  ActivityImageCell.swift
//  S10
//
//  Created by Tony Xiao on 6/27/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Core
import ReactiveCocoa

class ActivityImageCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var contentTextLabel: UILabel!
    @IBOutlet weak var serviceNameLabel: UILabel!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    
    var cd: CompositeDisposable!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.makeCircular()
        contentImageView.clipsToBounds = true
    }
    
    func bind(vm: ActivityImageViewModel) {
        cd = CompositeDisposable()
        cd.addDisposable(timestampLabel.rac_text <~ vm.displayTime)
        
        usernameLabel.text = vm.displayName
        contentTextLabel.text = vm.text
        serviceNameLabel.text = vm.integrationName
        serviceNameLabel.textColor = vm.integrationColor
        userImageView.rac_image.value = vm.avatar
        contentImageView.rac_image.value = vm.image
//        imageHeightConstraint.constant = CGFloat(vm.image.height ?? 0)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
    }
        
    static func reuseId() -> String {
        return reuseId(.ActivityImageCell)
    }
    
}