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
    public let connectionViewModels: DynamicArray<ConversationViewModel>
    
    public init() {
        frc = Connection.sorted(by: ConnectionKeys.updatedAt.rawValue, ascending: false).frc()
        connectionViewModels = frc.dynSections[0].map { (connection, _) in
            ConversationViewModel(connection: connection as! Connection)
        }
    }
}