//
//  AirEventTransmiiter.swift
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
class AirEventDecoder {
    private let eventCollector: AirEventObserver
    private let networkManager: AirNetworkManager
    private let sessionManager: AirSessionManager
    private let deeplinkManager: AirDeeplinkManager
    
    init(_ networkManager: AirNetworkManager = AirNetworkManager.shared,
         _ sessionManager: AirSessionManager = AirSessionManager.shared,
         _ deeplinkManager: AirDeeplinkManager = AirDeeplinkManager.shared,
         _ eventCollector: AirEventObserver = AirEventObserver()
    ) {
        self.networkManager = networkManager
        self.sessionManager = sessionManager
        self.deeplinkManager = deeplinkManager
        self.eventCollector = eventCollector
        
        self.eventCollector.delegate = self
    }
}

extension AirEventDecoder: EventObserverDelegate {
    func appDidBecomeInstalled() {
        networkManager.sendEventToServer(event: .organicInstall)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isInstalledKey)
    }

    @objc func appMovedToBackground() {
        networkManager.sendEventToServer(event: .background)
        sessionManager.setSessionTimeCurrent()
    }

    @objc func appCameToForeground() {        networkManager.sendEventToServer(event: .active)

        switch sessionManager.checkIfSessionIsVaild() {
        case .expired:
            // Open event
            if PersistentVariables.isDeeplinkActivated {
                networkManager.sendEventToServer(event: .deeplinkOpen)
                deeplinkManager.resetSchemeLinkStatus()
            } else {
                networkManager.sendEventToServer(event: .organicOpen)
            }
        case .valid:
            // Re-open event
            if PersistentVariables.isDeeplinkActivated {
                networkManager.sendEventToServer(event: .deeplinkReOpen)
                deeplinkManager.resetSchemeLinkStatus()
            } else {
                networkManager.sendEventToServer(event: .organicReOpen)
            }
        case .unrecorded:
            // Maybe an error
            AirLoggingManager.logger(message: "Session time is not recorded for an unknown reason", domain: "Error")
        }
    }
}
