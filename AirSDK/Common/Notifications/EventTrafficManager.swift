//
//  EventTrafficManaager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/31.
//

import Foundation

/// Control SDK's policy about event queueing and emittance from queues
class EventTrafficManager {
    static let shared = EventTrafficManager()
    
    /// A bool flag indicating wheter any requests has been processed or being processed
    private var currentWorkItem: DispatchWorkItem? = nil
    
    func startTracking() {
        TrafficNotificationCenter.default.post(name: TrafficNotification.start.name, object: nil, userInfo: nil)
    }
    
    func stopTracking() {
        TrafficNotificationCenter.default.post(name: TrafficNotification.stop.name, object: nil, userInfo: nil)
    }
    
    /// Sends a signal ATT timeout signal to `TrafficNotificationCenter`.
    ///
    /// When a new request came, the preceding one will be ignored.
    func waitingForATT(timeout: TimeInterval) {
        if let currentWorkItem = currentWorkItem {
            currentWorkItem.cancel()
            LoggingManager.logger(warning: "waitForATTtimeoutInteval has already been set before. It's replaced to the new value.")
        }
        
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            TrafficNotificationCenter.default.post(name: TrafficNotification.timeoutForATT.name, object: nil, userInfo: nil)
            self.currentWorkItem = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: workItem)
        
        self.currentWorkItem = workItem
    }
}
