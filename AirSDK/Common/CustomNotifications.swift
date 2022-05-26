//
//  Notifications.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/23.
//

import Foundation

/// Handling custom notifications used in the SDK through native `NotificationCenter`
class CustomNotifications {
    // TODO: Should ensure methods to be implemented only once
    // Tell duplicated requests from repeated requests
//    static private var isPosted = [NotificationName: Bool]()
    
    /// Post a signal to the designated `Notification.Name`
    ///
    /// - Parameters:
    ///     - name: A `NotificationName` value which is predefined set of names described in `enum` type
    static func post(name: NotificationName) {
//        if self.isPosted[name, default: false] == false {
//            self.isPosted[name] = true
            NotificationCenter.default.post(name: Notification.Name(name.rawValue), object: nil, userInfo: nil)
//        } else {
//            AirLoggingManager.logger(warning: "Notification has already been posted. Are you sure to post \"\(name)\" again?")
//        }
    }
    
    /// Get a `Notification.Name` for the specific event
    ///
    /// - Parameters:
    ///     - for: A `NotificationName` value which defines noticable events
    static func name(for notification: NotificationName) -> Notification.Name {
        return Notification.Name(notification.rawValue)
    }
}

extension CustomNotifications {
    enum NotificationName: String {
        case deeplink = "DeeplinkOpen"
    }
}
