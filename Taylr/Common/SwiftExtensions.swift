//
//  SwiftExtensions.swift
//  Taylr
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation

extension Zip2 {

    func map<U>(transform: (S0.Generator.Element, S1.Generator.Element) -> U) -> [U] {
        var results = [U]()
        for (e0, e1) in self {
            results.append(transform(e0, e1))
        }
        return results
    }
    
    func each(block: (S0.Generator.Element, S1.Generator.Element) -> ()) {
        for (e0, e1) in self {
            block(e0, e1)
        }
    }

}

extension String {
    func nonBlank() -> String? {
        let trimmed = stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        return trimmed.length > 0 ? trimmed : nil
    }
}