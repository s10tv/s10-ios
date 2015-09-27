//
//  Bond+JSBadgeView.swift
//  S10
//
//  Created by Tony Xiao on 7/29/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import JSBadgeView

extension JSBadgeView {
    public var rac_badgeText: Event<String, NoError>.Sink {
        return Event.sink(next: { [weak self] in self?.badgeText = $0 })
    }
}
