//
//  ConnectionCell.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Bond
import JSBadgeView
import Core

class ContactConnectionCell : UITableViewCell, BindableCell {
    
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var rightArrow: UIImageView!
    var badgeView: JSBadgeView!
    
    var cd: ReactiveCocoa.CompositeDisposable!
    
    func bind(vm: ContactConnectionViewModel) {
        cd = CompositeDisposable()
        cd.addDisposable { avatarView.sd_image <~ vm.avatar }
        cd.addDisposable { badgeView.rac_badgeText <~ vm.badgeText }
        cd.addDisposable { nameLabel.rac_text <~ vm.displayName }
        cd.addDisposable { subtitleLabel.rac_text <~ vm.statusMessage }
        cd.addDisposable { rightArrow.rac_hidden <~ vm.hideRightArrow }
        cd.addDisposable { spinner.rac_animating <~ vm.busy }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatarView.makeCircular()
        badgeView = JSBadgeView(parentView: self, alignment: .CenterRight)
        badgeView.badgeTextFont = UIFont(.cabinRegular, size: 12)
        badgeView.badgeStrokeWidth = 5
        badgeView.badgeStrokeColor = StyleKit.brandPurple
        badgeView.badgeBackgroundColor = StyleKit.brandPurple
        badgeView.badgePositionAdjustment = CGPoint(x: -22, y: 0)
    }
    
    static func reuseId() -> String {
        return reuseId(.ContactConnectionCell)
    }
}
