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
    
    /// Handle the event when `scheme link`'s received
    func handleSchemeLink(_ url: URL) {
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        AirLoggingManager.logger(message: "Deeplink(scheme) is activated(url: \"\(url)\")", domain: "AirSDK-Deeplink")
    }
    
    /// Handle the event when `universal link`'s received
    func handleUniversalLink(_ url: URL) throws {
        guard let parsedUrl = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw AirDeeplinkError.invalidUrl
        }
        
        guard let host = parsedUrl.host else {
            throw AirDeeplinkError.invalidHost
        }
        
        guard let queryItems = parsedUrl.queryItems else {
            throw AirDeeplinkError.invalidQueryItems
        }
        
        AirNetworkManager.shared.convertDeeplink(host, queryItems)
        
        UserDefaults.standard.set(true, forKey: userDefaultKey)
        AirLoggingManager.logger(message: "Deeplink(universal link) is activated(url: \"\(url.absoluteString)\")", domain: "AirSDK-Deeplink")
    }
    
    /// Set deep link status to default value
    ///
    /// It **must** be called after every deep link open event handlers.
    func resetSchemeLinkStatus() {
        UserDefaults.standard.set(false, forKey: userDefaultKey)
    }
}
