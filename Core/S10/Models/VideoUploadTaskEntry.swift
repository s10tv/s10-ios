//
//  VideoUploadTask.swift
//  S10
//
//  Created by Qiming Fang on 6/20/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import RealmSwift

public class VideoUploadTaskEntry : Object {
    dynamic var id = ""
    dynamic var recipientId = ""
    dynamic var localURL = ""

    override public static func primaryKey() -> String? {
        return "id"
    }
}