//
//  AirTrackableEvent.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/11.
//

import Foundation

@frozen enum AirTrackableEvent {
    case organicInstall
    case organicOpen
    case organicReOpen
    case active
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
        case .active:
            return "App become active"
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
