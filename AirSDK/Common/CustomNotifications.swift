//
//  Notifications.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/23.
//

import Foundation

class CustomNotifications {
    // TODO: Should ensure methods to be implemented only once
    
    static func post(name: NotificationName) {
        NotificationCenter.default.post(name: Notification.Name(name.rawValue), object: nil, userInfo: nil)
    }
    
    static func name(of notification: NotificationName) -> Notification.Name {
        return Notification.Name(notification.rawValue)
    }
}

extension CustomNotifications {
    enum NotificationName: String {
        case deeplink = "DeeplinkOpen"
    }
}
