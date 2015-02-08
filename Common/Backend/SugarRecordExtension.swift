//
//  SugarRecordExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/8/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import SugarRecord

extension SugarRecord {
    public class func transaction(closure: (context: SugarRecordContext) -> ()) {
        operation(.SugarRecordEngineCoreData, closure: { (context) -> () in
            context.beginWriting()
            closure(context: context)
            context.endWriting()
        })
    }
}

extension SugarRecordFinder {
    public func frc() -> NSFetchedResultsController {
        return fetchedResultsController(nil)
    }
}