//
//  MeteorCollection.swift
//  S10
//
//  Created by Tony Xiao on 7/14/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Meteor

struct BoxedValue {
    let value: AnyObject?
    func typed<T>(type: T.Type) -> T? {
        return value as? T
    }
}

class MeteorCollection {
    let nc = NSNotificationCenter.defaultCenter().proxy()
    let c: METCollection
    let databaseChanges: Signal<METDatabaseChanges, NoError>
    
    init(_ collection: METCollection) {
        let (signal, sink) = Signal<METDatabaseChanges, NoError>.pipe()
        c = collection
        databaseChanges = signal
        nc.listen(METDatabaseDidChangeNotification) { note in
            if let changes = note.userInfo?[METDatabaseChangesKey] as? METDatabaseChanges {
                sendNext(sink, changes)
            }
        }
    }
    
    func get(documentID: String, field: String = "value") -> BoxedValue {
        return BoxedValue(value: (c.documentWithID(documentID) as METDocument?)?.fields[field])
    }
    
    func signal(documentID: String, field: String = "value") -> Signal<BoxedValue, NoError> {
        let documentKey = METDocumentKey(collectionName: c.name, documentID: documentID)
        return databaseChanges
            |> filter { contains($0.affectedDocumentKeys(), documentKey) }
            |> map { $0.changeDetailsForDocumentWithKey(documentKey).fieldsAfterChanges?[field] }
            |> map { BoxedValue(value: $0) }
    }
    
    func mutableProperty(documentID: String, field: String = "value") -> MutableProperty<BoxedValue> {
        return MutableProperty(get(documentID, field: field)) { signal(documentID, field: field) }
    }
    
    func propertyOf(documentID: String, field: String = "value") -> PropertyOf<BoxedValue> {
        return PropertyOf(get(documentID, field: field)) { signal(documentID, field: field) }
    }
    
    func propertyOf<T>(documentID: String, field: String = "value", type: T.Type) -> PropertyOf<T?> {
        return propertyOf(documentID, field: field) |> { $0.typed(T.self) }
    }
    
    func propertyOf<T>(documentID: String, field: String = "value", defaultValue: T) -> PropertyOf<T> {
        return propertyOf(documentID, field: field) |> { $0.typed(T.self) ?? defaultValue }
    }
}
