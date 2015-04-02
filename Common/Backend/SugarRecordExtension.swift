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
    
    public func by(key: String, value: AnyObject?) -> SugarRecordFinder {
        return by(NSPredicate(format: "%K = %@", argumentArray: [key, value ?? NSNull()]))
    }
    
    public func frc() -> NSFetchedResultsController {
        return fetchedResultsController(nil)
    }
    
    public func fetch() -> [AnyObject] {
        return map(self.find(), { (record) -> AnyObject in
            return record
        })
    }
    
    public func fetchFirst() -> AnyObject? {
        return first().find().firstObject()
    }
}

extension NSManagedObject {
    class func by(key: String, value: AnyObject?) -> SugarRecordFinder {
        return all().by(key, value: value)
    }
}

// TODO: Separate file because it's unrelated to SugarRecord?
extension NSFetchedResultsController {
    func fetchObjects() -> [AnyObject] {
        if fetchedObjects == nil {
            var error: NSError?
            let success = performFetch(&error)
            if !success || error != nil {
                Log.error("Failed when fetch frc \(self)", error)
            }
        }
        return fetchedObjects ?? []
    }
}