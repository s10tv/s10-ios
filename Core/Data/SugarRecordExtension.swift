//
//  SugarRecordExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/8/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import CoreData
import SugarRecord
//import Bond

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
        return self.find().map { (record) -> AnyObject in
            return record
        }
    }
    
    public func fetchFirst() -> AnyObject? {
        return first().find().firstObject()
    }
    
    //    public func results<T : NSManagedObject>(type: T.Type, loadData: Bool = true) -> FetchedResultsArray<T> {
    //        return fetchedResultsController(nil).results(type, loadData: loadData)
    //    }
}

extension NSManagedObject {
    public class func by(key: String, value: AnyObject?) -> SugarRecordFinder {
        return all().by(key, value: value)
    }
    public class func by(key: CustomStringConvertible, value: AnyObject?) -> SugarRecordFinder {
        return by(key.description, value: value)
    }
}

// TODO: Separate file because it's unrelated to SugarRecord?
extension NSFetchedResultsController {
    public func fetchObjects() -> [AnyObject] {
        if fetchedObjects == nil {
            do {
                try self.performFetch()
            } catch let error as NSError {
                Log.error("Failed when fetch frc \(self)", error)
            }
        }
        return fetchedObjects ?? []
    }
}