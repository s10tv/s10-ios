//
//  AVKit.swift
//  S10
//
//  Created by Tony Xiao on 6/18/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import SCRecorder



class AVKit {
    static let defaultFilters = AVKit.allFilters()
    
    class func allFilters() -> [SCFilter] {
        let emptyFilter = SCFilter.emptyFilter()
        emptyFilter.name = "#nofilter"
        return [
            SCFilter(CIFilterName: "CIPhotoEffectChrome"),
            SCFilter(CIFilterName: "CIPhotoEffectMono"),
            SCFilter(CIFilterName: "CIPhotoEffectFade"),
            SCFilter(CIFilterName: "CIPhotoEffectInstant"),
            SCFilter(CIFilterName: "CIPhotoEffectNoir"),
            SCFilter(CIFilterName: "CIPhotoEffectProcess"),
            SCFilter(CIFilterName: "CIPhotoEffectTonal"),
            SCFilter(CIFilterName: "CIPhotoEffectTransfer"),
            emptyFilter,
        ]
    }
}