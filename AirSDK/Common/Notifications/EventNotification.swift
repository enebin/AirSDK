//
//  EventNotification.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/27.
//

import Foundation

enum EventNotification {
    case deeplink
    
    var name: Notification.Name {
        switch self {
        case .deeplink:
            return Notification.Name("deepLinkOpen")
        }
    }
}
