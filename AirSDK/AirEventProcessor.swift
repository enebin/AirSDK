//
//  AirEventDecoder.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

// TODO: Seperate network call -> maybe already done

/// Converts the observed event to a `AirTrackableEvent`
///
/// This class **should** conform `EventCollectorDelegate` to observe system events.
///
/// - Warning: It makes network request inside for now. You might consider splitting nework features later here.
class AirEventProcessor {
    private let eventObserver: AirEventObserver
    private let networkManager: AirAPIManager
    private let sessionManager: AirSessionManager
    private let deeplinkManager: AirDeeplinkManager
    
    init(_ networkManager: AirAPIManager = AirAPIManager.shared,
         _ sessionManager: AirSessionManager = AirSessionManager.shared,
         _ deeplinkManager: AirDeeplinkManager = AirDeeplinkManager.shared,
         _ eventObserver: AirEventObserver = AirEventObserver()
    ) {
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.deeplinkManager = deeplinkManager
        self.eventObserver = eventObserver
        
        self.eventObserver.delegate = self
    }
}

extension AirEventProcessor: EventObserverDelegate {
    func appDidBecomeInstalled() {
        networkManager.sendEventToServer(event: .organicInstall)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isInstalledKey)
    }

    func appDidBecomeActive() {
//        networkManager.sendEventToServer(event: .active)
        
        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            networkManager.sendEventToServer(event: .organicOpen)
        case .valid:
            // Re-open event
            networkManager.sendEventToServer(event: .organicReOpen)
        case .unrecorded:
            // Maybe an error
            AirLoggingManager.logger(message: "Session time is not recorded", domain: "Error")
        }
    }
    
    func appCameToForegroundWithDeeplink() {
//        networkManager.sendEventToServer(event: .active)
        
        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            networkManager.sendEventToServer(event: .deeplinkOpen)
        case .valid:
            // Re-open event
            networkManager.sendEventToServer(event: .deeplinkReOpen)
        case .unrecorded:
            // Maybe an error
            AirLoggingManager.logger(message: "Session time is not recorded for an unknown reason", domain: "Error")
        }
    }
    
    func appMovedToBackground() {
        networkManager.sendEventToServer(event: .background)
        sessionManager.setSessionTimeToCurrent()
    }
}

