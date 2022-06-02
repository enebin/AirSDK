//
//  TrafficNotification.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/31.
//

import Foundation

enum TrafficNotification {
    case start
    case stop
    case timeoutForATT
    
    var name: Notification.Name {
        switch self {
        case .start:
            return Notification.Name("start")
        case .stop:
            return Notification.Name("stop")
        case .timeoutForATT:
            return Notification.Name("ATT")
        }
    }
}

