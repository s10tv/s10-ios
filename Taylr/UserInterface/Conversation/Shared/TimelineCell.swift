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
    var vm: MessageViewModel?
    
    func bind(vm: MessageViewModel) {
        self.vm = vm
        cd = CompositeDisposable()
        imageView.sd_image.value = vm.thumbnail
        badgeView.hidden = !vm.unread
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cd.dispose()
        imageView.sd_image.value = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.userInteractionEnabled = true
        imageView.whenLongPressed { [weak self] gesture in
            // TODO: Move this into the delegate of timeline cell
            if gesture.state == .Began {
                let sheet = UIAlertController(
                    title: self?.vm?.senderInfo,
                    message: self?.vm?.messageInfo,
                    preferredStyle: .ActionSheet
                )
                if self?.vm?.outgoing == true {
                    sheet.addAction("Delete Message", style: .Destructive) { _ in
                    }
                }
                sheet.addAction("Close", style: .Cancel)
                self?.window?.rootViewController?.presentViewController(sheet)
            }
        }
    }
    
    static func reuseId() -> String {
        return reuseId(.TimelineCell)
    }
}