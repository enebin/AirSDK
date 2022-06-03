//
//  AirEventDecoder.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

/// Converts the observed event to a `TrackableEvent`
///
/// This class **should** conform `EventCollectorDelegate` to observe system events.
///
/// - Warning: It makes network request inside for now. You might consider splitting nework features later here.
class EventProcessor {
    // Dependencies
    private let eventObserver: EventObserver
    private let sessionManager: SessionManager
    private let deeplinkManager: DeeplinkManager
    private let eventQueueManager: EventQueueManager
    private let options: AirConfigOptions
    
    // Initializer
    init(_ sessionManager: SessionManager = SessionManager.shared,
         _ deeplinkManager: DeeplinkManager = DeeplinkManager.shared,
         _ eventObserver: EventObserver = EventObserver(),
         options: AirConfigOptions
    ) {
        self.sessionManager = sessionManager
        self.deeplinkManager = deeplinkManager
        self.eventObserver = eventObserver
        
        self.options = options
        self.eventQueueManager = EventQueueManager(options: options)
        
        self.eventObserver.delegate = self
    }
}

extension EventProcessor: EventObserverDelegate {
    typealias Install = TrackableEvents.installEvent
    typealias System = TrackableEvents.systemEvent
    typealias Custom = TrackableEvents.customEvent
    
    
    func appDidBecomeInstalled() {
        eventQueueManager.addToQueue(event: Install.organicInstall)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isInstalledKey)
    }

    func appDidBecomeActive() {
//        networkManager.sendEventToServer(event: .active)

        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            eventQueueManager.addToQueue(event: System.organicOpen)
        case .valid:
            // Re-open event
            eventQueueManager.addToQueue(event: System.organicReOpen)
        case .unrecorded:
            // Maybe an error
            // MARK: Currently, it's handled as organic open
            eventQueueManager.addToQueue(event: System.organicOpen)
            LoggingManager.logger(message: "Session time is not recorded. It will be recorded as OrganicOpen.", domain: "Error")
        }
    }
    
    func appCameToForegroundWithDeeplink() {
//        networkManager.sendEventToServer(event: .active)
        
        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            eventQueueManager.addToQueue(event: System.deeplinkOpen)
        case .valid:
            // Re-open event
            eventQueueManager.addToQueue(event: System.deeplinkReOpen)
        case .unrecorded:
            // Maybe an error
            // MARK: Currently, it's handled as deeplink open
            eventQueueManager.addToQueue(event: System.deeplinkOpen)

            LoggingManager.logger(message: "Session time is not recorded. Deeplink open event is ignored.", domain: "Error")
        }
    }
    
    func appMovedToBackground() {
        eventQueueManager.addToQueue(event: System.background)
        sessionManager.setSessionTimeToCurrent()
    }
    
    func didReceiveCustomEvent(_ event: Custom) {
        eventQueueManager.addToQueue(event: event)
    }
}

