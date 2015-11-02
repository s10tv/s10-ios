//
//  MainViewManager.swift
//  S10
//
//  Created by Tony Xiao on 11/2/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation

@objc(MainViewManager)
class MainViewManager : NSObject {
    
    @objc func testMethod(string: String, alt: String) {
        print("Test method called in MainViewManager \(string) alt: \(alt)")
    }
}