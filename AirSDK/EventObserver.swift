//
//  AirEventDecoder.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

/// Observe the app's life cycle events using system's `NotifacationCenter`
///
/// If it doesn't work as you expected, please make sure you have passed a `delegate` instance.
///
/// - Warning: Make sure that the instance is created only once.
///     You will get duplicated data if there are more than an instance created,
///     which wastes valuable memory.
class EventObserver {
    weak var delegate: EventObserverDelegate? {
        // - ???: To be discussed
        // This `didSet` approach forces the SDK to be configured in main thread.
        // If the app become foreground before the SDK completes configuration,
        // it is possible the first foreground event will be ignored.
        didSet {
            self.setNotifications()
        }
    }
    
    /// A bool signal indicating whether the app is opened with deeplink
    private var isDeeplinkActivated = false
        
    private func setNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppMovedToBackground),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        
        EventNotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppCameToForegroundWithDeeplink),
                                                    name: EventNotification.deeplink.name,
                                               object: nil)
        
        EventNotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didReceiveCustomEvent),
                                                    name: EventNotification.custom.name,
                                               object: nil)
        
        // Not a notification. It works anyway...
        if PersistentVariables.isInstalledBefore != true {
            self.notifiedAppDidBecomeInstalled()
        }
    }
    
    /// Called when the app is first installed
    private func notifiedAppDidBecomeInstalled() {
        delegate?.appDidBecomeInstalled()
    }
    
    /// Called after the app is opened and `AirSDK.handleDeeplink()` is called
    @objc private func notifiedAppCameToForegroundWithDeeplink() {
        self.isDeeplinkActivated = true
    }
    
    /// Called after the app goes to background
    @objc private func notifiedAppDidBecomeActive() {
        if self.isDeeplinkActivated {
            delegate?.appCameToForegroundWithDeeplink()
            self.isDeeplinkActivated = false
        } else {
            delegate?.appDidBecomeActive()
        }
    }
    
    /// Called after the app comes to foreground
    @objc private func notifiedAppMovedToBackground() {
        delegate?.appMovedToBackground()
    }
    
    /// Called after custom event generated
    @objc private func didReceiveCustomEvent(_ notification: Notification) {
        if let dataDict = notification.userInfo as Dictionary? {
            guard let eventLabel = dataDict["label"] as? String else {
                return
            }
            
            delegate?.didReceiveCustomEvent(TrackableEvents.customEvent(label: eventLabel))
        }
    }
}
