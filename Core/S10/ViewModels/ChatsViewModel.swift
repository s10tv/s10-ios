//
//  ChatsViewModel.swift
//  Taylr
//
//  Created by Tony Xiao on 6/12/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import Foundation
import CoreData
import Bond

public class ChatsViewModel {
    private let frc : NSFetchedResultsController
    public let connections: DynamicArray<Connection>
    
    public init() {
        frc = Connection.sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false).frc()
        connections = frc.dynSections[0].map { (o, _) in o as! Connection }
    }
}