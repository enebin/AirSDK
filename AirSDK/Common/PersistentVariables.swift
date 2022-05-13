//
//  AirComon.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation

/// Provide persistent variables used through the whole project
struct PersistentVariables {
    static var isInstalledBefore: Bool {
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isInstalledKey) {
            return true
        } else {
            return false
        }
    }
    
    // Can replace `isInstalledBefore` with this?
    /// Variable which holds the last recorded session timestamp
    ///
    /// In other words, `lastRecordedSessionTime` holds
    /// the value of the moment  the app went to background.
    ///
    /// - Returns: `timeIntervalSince1970` in `Double` type
    static var lastRecordedSessionTime: Double? {
        return UserDefaults.standard.object(forKey: UserDefaultKeys.lastRecordedSessionTimeKey) as? Double
    }
    
    /// Variable which holds if the app is opened with Deeplink or not
    ///
    /// - Returns: If the app is opened with Deeplink, it gives  you `true`, otherwise `false` in `Bool` type
    static var isDeeplinkActivated: Bool {
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isOpenedWithDeeplinkKey) {
            return true
        } else {
            return false
        }
    }
}
