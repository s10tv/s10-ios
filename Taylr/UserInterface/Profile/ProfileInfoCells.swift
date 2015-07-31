//
//  ProfileInfoCells.swift
//  S10
//
//  Created by Tony Xiao on 7/26/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import Bond
import Core

class TaylrProfileInfoCell : UITableViewCell, BindableCell {
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    
    func bind(vm: TaylrProfileInfoViewModel) {
        vm.tagline ->> taglineLabel
        vm.about ->> aboutLabel
    }
    
    static func reuseId() -> String {
        return reuseId(.TaylrProfileInfoCell)
    }
}

class ConnectedProfileInfoCell : UITableViewCell, BindableCell {
    
    func bind(vm: ConnectedProfileInfoViewModel) {
        
    }
    
    static func reuseId() -> String {
        return ""
    }
}