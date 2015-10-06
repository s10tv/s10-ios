//
//  TimelineCell.swift
//  S10
//
//  Created by Tony Xiao on 10/4/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Core

class TimelineCell : UICollectionViewCell, BindableCell {
    typealias ViewModel = MessageViewModel
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var badgeView: UIView!
    
    var cd: CompositeDisposable!
    
    func bind(vm: MessageViewModel) {
        cd = CompositeDisposable()
        imageView.sd_image.value = vm.thumbnail
        badgeView.hidden = !vm.unread
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
        imageView.sd_image.value = nil
    }
    
    static func reuseId() -> String {
        return reuseId(.TimelineCell)
    }
}