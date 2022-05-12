//
//  AirDeeplink.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// Manage actions related to Deeplink
class AirDeeplinkManager {
    private let userDefaultKey = UserDefaultKeys.isOpenedWithDeeplinkKey
    
    func handleSchemeLink(_ url: URL) {
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        AirLoggingManager.logger(message: "Deeplink is activated(url: \"\(url.absoluteString)\")", domain: "AirDeeplink")
    }
    
    func resetSchemeLinkStatus() {
        UserDefaults.standard.set(false, forKey: userDefaultKey)
    }
}
