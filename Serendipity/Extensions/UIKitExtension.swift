//
//  UIKitExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/6/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

extension UIView {
    func makeCircular() {
        layer.cornerRadius = max(frame.size.width, frame.size.height) / 2;
        layer.masksToBounds = true;
    }
}
