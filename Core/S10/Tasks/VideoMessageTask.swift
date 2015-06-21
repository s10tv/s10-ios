//
//  VideoMessageTask.swift
//  Taylr
//
//  Created by Tony Xiao on 6/16/15.
//  Copyright (c) 2015 Taylr. All rights reserved.
//

import Foundation
import ReactiveCocoa

class VideoMessageTask : Task {
    var connectionId: String!
    var videoPath: String!
    var coverFramePath: String!

}

public class SendVideoOperation : AsyncOperation {
    
    public override func run() {
        // DO whatever you want
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.finish(.Success)
        }
        // instantiate by TaskID
        // Gets task from DB by ID
        // Request URL from server
        // Write url to db
        // Uplaod to azure
        // delete row from db
        // call finish
    }
}



