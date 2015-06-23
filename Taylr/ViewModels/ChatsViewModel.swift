//
//  ChatsViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import Core
import Bond

class ChatsViewModel {
    private let frc : NSFetchedResultsController
    let connections: DynamicArray<Connection>
    
    init() {
        frc = Connection.sorted(by: ConnectionAttributes.updatedAt.rawValue, ascending: false).frc()
        connections = frc.dynSections[0].map { (o, _) in o as! Connection }
    }
}