//
//  CustomEventManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/30.
//

import Foundation

class CustomEventManager {
    static let shared = CustomEventManager()
    
    func handleCustomEvent(_ event: TrackableEvents.customEvent) {
        EventNotificationCenter.default.post(name: EventNotification.custom.name,
                                             object: nil,
                                             userInfo: ["label": event.label])
    }
}
