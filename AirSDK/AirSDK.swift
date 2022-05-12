//
//  AirSDK.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation
import UIKit

/// Main class of the SDK
public class AirSDK {
    // MARK: - Instances
    static var shared: AirSDK?
    static var networkManager = AirNetworkManager()
    static var deeplinkManager = AirDeeplinkManager()
    static var sessionManager = AirSessionManager()
    
    
    // MARK: - Public methods
    
    /// Initializes AirSDK
    ///
    /// Configures a default AirSDK instance.
    /// Raises an error if any configuration step fails.
    /// This method should be called from the main thread.
    public static func configure() {
        do {
            if self.shared != nil {
                throw AirConfigError.alreadyInitialized
            }
            
            if PersistentVariables.isInstalledBefore != true {
                self.appDidBecomeInstalled()
            }
                        
            self.shared = AirSDK()
            self.setNotifications()
            
            AirLoggingManager.logger(message: "AirSDK is initialized",
                                     domain: "AirSDK")
        } catch let error {
            // FIXME: Write error handling codes in here
            AirLoggingManager.logger(error: error)
        }
    }
    
    /// Sends a user defined event to the server
    ///
    /// Raises an error if any configuration step fails.
    public static func sendCustomEvent(_ event: String) {
        do {
            try checkIfInitialzed(shared)
            networkManager.sendEventToServer(event: .custom(label: event))
        } catch let error {
            AirLoggingManager.logger(error: error)
        }
        
    }
    
    /// Temporary Deeplink handler
    ///
    /// Raises an error if any configuration step fails.
    public static func handleSchemeLink(_ url: URL) {
        do {
            try checkIfInitialzed(shared)
            deeplinkManager.handleSchemeLink(url)
        } catch let error {
            AirLoggingManager.logger(error: error)
        }
    }
    
    // MARK: - Internal methods
    /// Checks if SDK has been initialized properly
    static func checkIfInitialzed(_ instance: AirSDK?) throws {
        // What if whether configured or not doesn't matter?
        if instance == nil {
            throw AirConfigError.notInitialized
        }
    }
    
    /// Sets notifications observing the app's life cycles
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


// MARK: - Define actions based on the app's life cycle

extension AirSDK: LifeCycleTracker {
    /// Called when the app is first installed
    static func appDidBecomeInstalled() {
        networkManager.sendEventToServer(event: .organicInstall)
        UserDefaults.standard.set(true, forKey: UserDefaultKeys.isInstalledKey)
    }
    
    /// Called after the app goes to background
    @objc static func appMovedToBackground() {
        networkManager.sendEventToServer(event: .background)
        sessionManager.setSessionTimeCurrent()
    }
    
    /// Called after the app comes to foreground
    @objc static func appCameToForeground() {
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
