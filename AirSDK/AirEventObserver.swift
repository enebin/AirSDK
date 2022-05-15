//
//  AirEventDecoder.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

/// Observe the app's life cycle events using iOS' `NotifacationCenter`
///
/// If it doesn't work as you expected, please make sure you have passed a `delegate` instance.
///
/// - Warning: Make sure that the instance is created only once.
///     Observed lifecycle events are duplicated when more than one instance is created,
///     which leads the app to waste its memory.
class AirEventObserver {
    var delegate: EventObserverDelegate? {
        // - ???: To be discussed
        // This didSet approach forces the SDK to be configured in main thread
        // because if the app become foreground before the SDK completes configuration,
        // the first foreground event will be ignored.
        didSet {
            self.setNotifications()
        }
    }
        
    func setNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppCameToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        // Not a notification.. anyway it works
        if PersistentVariables.isInstalledBefore != true {
            self.notifiedAppDidBecomeInstalled()
        }
    }
    
    /// Called when the app is first installed
    func notifiedAppDidBecomeInstalled() {
        delegate?.appDidBecomeInstalled()
    }
    
    /// Called after the app goes to background
    @objc func notifiedAppCameToForeground() {
        delegate?.appCameToForeground()
    }
    
    /// Called after the app comes to foreground
    @objc func notifiedAppMovedToBackground() {
        delegate?.appMovedToBackground()
    }
}
