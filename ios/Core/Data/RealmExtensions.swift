//
//  RealmExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/11/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveCocoa

extension Realm {
    func notifier() -> SignalProducer<Notification, NoError> {
        return SignalProducer { sink, disposable in
            let token = self.addNotificationBlock { note, realm in
                sendNext(sink, note)
            }
            disposable.addDisposable {
                self.removeNotification(token)
            }
        }
    }
}

func unsafeNewRealm() -> Realm {
    return (try? Realm())!
}