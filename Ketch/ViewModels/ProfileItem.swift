//
//  Profile.swift
//  Ketch
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class ProfileInfoItem {
    enum ItemType {
        case Location(String), Age(Int), Height(Int), Work(String), Education(String)
    }
    let type : ItemType
    let imageName : R.KetchAssets
    let minWidthRatio : CGFloat = 1
    
    var image : UIImage! {
        return UIImage(named: imageName.rawValue)
    }
    
    var text : String {
        
        
        switch type {
        case let .Location(location): return location
        case let .Age(age): return toString(age)
        case let .Height(height): return Formatters.formatHeight(height)
        case let .Work(work): return work
        case let .Education(education): return education
        }
    }
    
    init(_ type: ItemType) {
        self.type = type
        switch type {
        case .Location:
            imageName = R.KetchAssets.settingsLocation
        case .Age:
            imageName = R.KetchAssets.settingsAge
            minWidthRatio = 0
        case .Height:
            imageName = R.KetchAssets.settingsHeightArrow
            minWidthRatio = 0
        case .Work:
            imageName = R.KetchAssets.settingsBriefcase
        case .Education:
            imageName = R.KetchAssets.settingsMortarBoard
        }
    }
}