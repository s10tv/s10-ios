//
//  Profile.swift
//  Taylr
//
//  Created by Tony Xiao on 4/17/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import Core

class ProfileInfoItem {
    enum ItemType {
        case Location(String), Age(Int), Height(Int), Work(String), Education(String)
    }
    let type : ItemType
    let imageName : R.TaylrAssets
    let minWidthRatio : CGFloat
    
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
//            imageName = R.TaylrAssets.settingsLocation
            minWidthRatio = 1
        case .Age:
//            imageName = R.TaylrAssets.settingsAge
            minWidthRatio = 0
        case .Height:
//            imageName = R.TaylrAssets.settingsHeightArrow
            minWidthRatio = 0
        case .Work:
//            imageName = R.TaylrAssets.settingsBriefcase
            minWidthRatio = 1
        case .Education:
//            imageName = R.TaylrAssets.settingsMortarBoard
            minWidthRatio = 1
        }
        imageName = R.TaylrAssets.icMe
    }
}