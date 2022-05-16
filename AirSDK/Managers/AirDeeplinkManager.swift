//
//  AirDeeplink.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// Manage actions related to Deeplink
class AirDeeplinkManager {
    static let shared = AirDeeplinkManager()
    
    private let userDefaultKey = UserDefaultKeys.isOpenedWithDeeplinkKey
    // Not implemented when app has killed and then opened
    func handleSchemeLink(_ url: URL) {
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        AirLoggingManager.logger(message: "Deeplink(scheme) is activated(url: \"\(url.absoluteString)\")", domain: "AirSDK-Deeplink")
    }
    
    func handleUniversalLink(_ url: URL) {
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        AirLoggingManager.logger(message: "Deeplink(universal link) is activated(url: \"\(url.absoluteString)\")", domain: "AirSDK-Deeplink")
    }
    
    func resetSchemeLinkStatus() {
        UserDefaults.standard.set(false, forKey: userDefaultKey)
    }
}
