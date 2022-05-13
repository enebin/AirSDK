//
//  AirEventTransmiiter.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

/// Wrapping the observed event to a AirTrackableEvent
class AirEventDecoder {
    init(_ networkManager: AirNetworkManager = AirNetworkManager.shared,
         _ sessionManager: AirSessionManager = AirSessionManager.shared,
         _ deeplinkManager: AirDeeplinkManager = AirDeeplinkManager.shared,
         _ eventCollector: AirEventCollector = AirEventCollector()
    ) {
        
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.deeplinkManager = deeplinkManager
        
        self.eventCollector = eventCollector
        eventCollector.delegate = self
        
        self.configure()
    }
    
    let eventCollector: AirEventCollector
    let networkManager: AirNetworkManager
    let sessionManager: AirSessionManager
    let deeplinkManager: AirDeeplinkManager
    
    func configure() {
        if PersistentVariables.isInstalledBefore != true {
            self.appDidBecomeInstalled()
        }
    }
}

extension AirEventDecoder: EventCollectorDelegate {
    /// Called when the app is first installed
    func appDidBecomeInstalled() {
        networkManager.sendEventToServer(event: .organicInstall)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isInstalledKey)
    }

    /// Called after the app goes to background
    @objc func appMovedToBackground() {
        networkManager.sendEventToServer(event: .background)
        sessionManager.setSessionTimeCurrent()
    }

    /// Called after the app comes to foreground
    @objc func appCameToForeground() {
        networkManager.sendEventToServer(event: .foreground)

        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            if PersistentVariables.isDeeplinkActivated {
                networkManager.sendEventToServer(event: .deeplinkOpen)
                deeplinkManager.resetSchemeLinkStatus()
            } else {
                networkManager.sendEventToServer(event: .organicOpen)
            }
            break
        case .valid:
            // Re-open event
            if PersistentVariables.isDeeplinkActivated {
                networkManager.sendEventToServer(event: .deeplinkReOpen)
                deeplinkManager.resetSchemeLinkStatus()
            } else {
                networkManager.sendEventToServer(event: .organicReOpen)
            }
            break
        case .unrecorded:
            // Maybe error
            AirLoggingManager.logger(message: "Unknown error. Session time is unrecorded", domain: "Error")
            break
        }
    }
}
