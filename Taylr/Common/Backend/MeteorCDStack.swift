//
//  MeteorCDStack.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/8/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import Foundation
import SugarRecord
import Meteor
import Core

class MeteorCDStack : SugarRecordStackProtocol {
    let name = "MeteorCDStack"
    let stackType = SugarRecordEngine.SugarRecordEngineCoreData
    let stackDescription = "CoreData stack that works with Meteor-ios"
    private(set) var stackInitialized : Bool = false
    
    let meteor : METCoreDataDDPClient
    var mainContext : NSManagedObjectContext?
    var privateContext : NSManagedObjectContext?
    
    init(meteor: METCoreDataDDPClient) {
        self.meteor = meteor
    }
    
    func saveChanges() {
        // Defining saving closure
        let save = { (context: NSManagedObjectContext) -> () in
            var error: NSError?
            context.save(&error)
            if error != nil {
                Log.error("Pending changes in the main context couldn't be saved", error)
            } else {
                Log.info("Existing changes persisted to the database")
            }
// TODO: Not clear why, but this crashes sometimes. Commenting out in attempt to fix
// https://fabric.io/ketch-app/ios/apps/com.milasya.ketch.dev/issues/55380d655141dcfd8f8bc896/sessions/553805da00e5000103de373436616236
//            context.reset()
        }
        
        // Saving MAIN Context
        mainContext?.performBlockAndWait {
            if self.mainContext!.hasChanges {
                save(self.mainContext!)
            }
        }
    }
    
    // MARK: - SugarRecordStackProtocol
    
    func initialize() {
        Log.info("Initializing the stack: \(name)")
        mainContext = meteor.mainQueueManagedObjectContext
        privateContext = NSManagedObjectContext(concurrencyType: .ConfinementConcurrencyType)
        privateContext!.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        privateContext!.parentContext = mainContext
        privateContext!.addObserverToGetPermanentIDsBeforeSaving()
        privateContext?.name = "Private Context (child of main)"
        stackInitialized = true
    }
    
    func removeDatabase() {
        Log.info("Not removing DB \(name). METIncrementalStore is in memory")
    }
    
    func cleanup() {
        Log.info("Cleanup called on \(name). Nothing to do here")
    }
    
    func applicationWillResignActive() {
        saveChanges()
    }
    
    func applicationWillTerminate() {
        saveChanges()
    }
    
    func applicationWillEnterForeground() {
        // Nothing to do here
    }
    
    func backgroundContext() -> SugarRecordContext? {
        return privateContext != nil ? SugarRecordCDContext(context: privateContext!) : nil
    }
    
    func mainThreadContext() -> SugarRecordContext? {
        return mainContext != nil ? SugarRecordCDContext(context: mainContext!) : nil
    }

}