//
//  AirEventDecoder.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

// TODO: Seperate network call -> maybe already done

/// Converts the observed event to a `TrackableEvent`
///
/// This class **should** conform `EventCollectorDelegate` to observe system events.
///
/// - Warning: It makes network request inside for now. You might consider splitting nework features later here.
class EventProcessor {
    private let eventObserver: EventObserver
    private let sessionManager: SessionManager
    private let deeplinkManager: DeeplinkManager
    private let eventQueueManager: EventQueueManager
    
    init(_ sessionManager: SessionManager = SessionManager.shared,
         _ deeplinkManager: DeeplinkManager = DeeplinkManager.shared,
         _ eventObserver: EventObserver = EventObserver(),
         _ eventQueueManager: EventQueueManager = EventQueueManager()
    ) {
        self.eventQueueManager = eventQueueManager
        self.sessionManager = sessionManager
        self.deeplinkManager = deeplinkManager
        self.eventObserver = eventObserver
        
        self.eventObserver.delegate = self
    }
}

extension EventProcessor: EventObserverDelegate {
    func appDidBecomeInstalled() {
        eventQueueManager.addQueue(event: .organicInstall)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isInstalledKey)
    }

    func appDidBecomeActive() {
//        networkManager.sendEventToServer(event: .active)
        
        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            eventQueueManager.addQueue(event: .organicOpen)
        case .valid:
            // Re-open event
            eventQueueManager.addQueue(event: .organicReOpen)
        case .unrecorded:
            // Maybe an error
            LoggingManager.logger(message: "Session time is not recorded", domain: "Error")
        }
    }
    
    func appCameToForegroundWithDeeplink() {
//        networkManager.sendEventToServer(event: .active)
        
        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            eventQueueManager.addQueue(event: .deeplinkOpen)
        case .valid:
            // Re-open event
            eventQueueManager.addQueue(event: .deeplinkReOpen)
        case .unrecorded:
            // Maybe an error
            LoggingManager.logger(message: "Session time is not recorded", domain: "Error")
        }
    }
    
    func appMovedToBackground() {
        eventQueueManager.addQueue(event: .background)
        sessionManager.setSessionTimeToCurrent()
    }
}

