//
//  AirComon.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation

/// Provides variables commonly used in the whole project
struct PersistentVariables {
    static var isInstalledBefore: Bool {
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isInstalledKey) {
            return true
        } else {
            return false
        }
    }
    
    // Can replace isInstalledBefore with this?
    /// Session time holds the value of the moment at the app went to background.
    static var lastRecordedSessionTime: Double? {
        return UserDefaults.standard.object(forKey: UserDefaultKeys.lastRecordedSessionTimeKey) as? Double
    }
    
    static var isDeeplinkActivated: Bool {
        if UserDefaults.standard.bool(forKey: UserDefaultKeys.isOpenedWithDeeplinkKey) {
            return true
        } else {
            return false
        }
    }
}
