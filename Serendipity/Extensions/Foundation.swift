//
//  Foundation.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/4/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation

extension Array {

    /**
    Deletes all the items in self that are equal to element.
    
    :param: element Element to remove
    */
    mutating func remove <U: Equatable> (element: U) {
        let anotherSelf = self
        removeAll(keepCapacity: true)
        
        for (index, current) in enumerate(anotherSelf) {
            if current as U != element {
                self.append(current)
            }
        }
    }
    
    func randomElement() -> T {
        let index = Int(arc4random_uniform(UInt32(count)))
        return self[index]
    }
}