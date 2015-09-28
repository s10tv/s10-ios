//
//  MediaExtension.swift
//  S10
//
//  Created by Tony Xiao on 6/21/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import CoreMedia

extension CMTime {
    public var seconds: Float64 {
        return CMTimeGetSeconds(self)
    }
    public var isValid: Bool { return flags.contains(.Valid) }
    public var impliedValue: Bool { return flags.contains(.ImpliedValueFlagsMask) }
}