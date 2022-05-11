//
//  AirComon.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation

/// SDK 전반에 걸쳐 공통적으로 사용되는 환경변수와 enum을 제공하는 구조체입니다.
struct AirCommon {
    static var isInstalledBefore: Bool {
        if UserDefaults.standard.bool(forKey: AirConstant.isInstalledKey) {
            return true
        } else {
            return false
        }
    }
    
    // Can replace isInstalledBefore with this?
    /// Session time holds the value of the moment at the app went to background.
    static var lastRecordedSessionTime: Double? {
        return UserDefaults.standard.object(forKey: AirConstant.lastRecordedSessionTimeKey) as? Double
    }
    
    static var isDeeplinkActivated: Bool {
        if UserDefaults.standard.bool(forKey: AirConstant.isOpenedWithDeeplinkKey) {
            return true
        } else {
            return false
        }
    }
    
    enum TrackableEvent {
        case organicInstall
        case organicOpen
        case organicReOpen
        case foreground
        case background
        case deeplinkInstall
        case deeplinkOpen
        case deeplinkReOpen
        case custom(label: String)
        
        var message: String {
            switch self {
            case .organicInstall:
                return "App is now installed"
            case .organicOpen:
                return "App is opened"
            case .organicReOpen:
                return "App is reopened"
            case .foreground:
                return "App enters foreground"
            case .background:
                return "App enters background"
            case .deeplinkInstall:
                return "App is now installed with Deeplink"
            case .deeplinkOpen:
                return "App is opened with Deeplink"
            case .deeplinkReOpen:
                return "App is reopened with Deeplink"
            case .custom(let label):
                return label
            }
        }
    }
}
