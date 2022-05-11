//
//  AirSDK.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation
import UIKit

// TODO: Configure check

/// Main class of the SDK
public class AirSDK {
    public init() {}
    static var shared: AirSDK?
    
    // MARK: - Public methods
    /// Initializing AirSDK
    public static func configure() {
        if self.shared != nil {
            AirLoggingManager.logger(message: "AirSDK has already been initialized", domain: "Error")
            return
        }
        
        self.shared = AirSDK()
        self.setNotifications()
        
        if AirCommon.isInstalledBefore != true {
            self.appDidBecomeInstalled()
        }
    }
    
    /// Temporary sender method
    public static func sendEvent(_ event: String) {
        AirNetworkManager.sendEventToServer(.custom(label: event))
    }
    
    /// Temporary Deeplink handler method
    public static func handleSchemeLink(_ url: URL) {
        do {
            try AirDeeplinkManager.handleSchemeLink(url)
        } catch(let error) {
          print(error)
        }
    }
    
    /// Check if SDK is initialized properly
    static func configureChecker() -> AirSDK? {
        return self.shared
    }
    
    // MARK: - Set notifications observing the app's life cycles
    static func setNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.appCameToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
}

extension AirSDK: LifeCycleTracker {
    // MARK: - Define actions based on life cycles
    @objc static func appMovedToBackground() {
        AirNetworkManager.sendEventToServer(.background)
        AirSessionManager.setSessionTimeToCurrentTime()
    }
    
    @objc static func appCameToForeground() {
        AirNetworkManager.sendEventToServer(.foreground)

        switch AirSessionManager.checkIfSessionIsVaild() {
        case .expired:
            if AirCommon.isDeeplinkActivated {
                AirNetworkManager.sendEventToServer(.deeplinkOpen)
                AirDeeplinkManager.resetSchemeLinkStatus()
            } else {
                AirNetworkManager.sendEventToServer(.organicOpen)
            }
            break
        case .valid:
            if AirCommon.isDeeplinkActivated {
                AirNetworkManager.sendEventToServer(.deeplinkReOpen)
                AirDeeplinkManager.resetSchemeLinkStatus()
            } else {
                AirNetworkManager.sendEventToServer(.organicReOpen)
            }
            break
        case .unrecorded:
            AirLoggingManager.logger(message: "Unknown error. Session time is unrecorded", domain: "Error")
            break
        }
    }
    
    static func appDidBecomeInstalled() {
        AirNetworkManager.sendEventToServer(.organicInstall)
        UserDefaults.standard.set(true, forKey: AirConstant.isInstalledKey)
    }
}
