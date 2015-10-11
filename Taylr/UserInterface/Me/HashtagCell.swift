//
//  HashtagCell.swift
//  S10
//
//  Created by Tony Xiao on 10/9/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import Core

class HashtagCell: UICollectionViewCell, BindableCell {
    typealias ViewModel = HashtagViewModel
    
    @IBOutlet weak var label: UILabel!
    
    func bind(vm: HashtagViewModel) {
        label.text = vm.displayText
        backgroundColor = vm.selected ? UIColor(hex: 0x7E57C2) : UIColor(hex: 0xE1DFDF)
        label.textColor = vm.selected ? UIColor.whiteColor() : UIColor(hex: 0x656567)
    }
    
    static func reuseId() -> String {
        return reuseId(.HashtagCell)
    }
}