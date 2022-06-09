//
//  AirTrackableEvent.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/11.
//

import Foundation

struct TrackableEvents {
    enum customEvent: TrackableEvent {
        case custom(message: String)
        
        var type: TrackableEventType {
            return .custom
        }
        
        var message: String {
            switch self {
            case .custom(let message):
                return message
            }
        }
    }
    
    enum systemEvent: TrackableEvent {
        case active
        case background
        case organicOpen
        case organicReOpen
        case deeplinkOpen
        case deeplinkReOpen
        
        var type: TrackableEventType {
            return .system
        }
        
        var message: String {
            switch self {
            case .organicOpen:
                return "App is opened"
            case .organicReOpen:
                return "App is reopened"
            case .active:
                return "App become active"
            case .background:
                return "App enters background"
            case .deeplinkOpen:
                return "App is opened with Deeplink"
            case .deeplinkReOpen:
                return "App is reopened with Deeplink"
            }
        }
    }
    
    enum installEvent: TrackableEvent {
        case organicInstall
        case deeplinkInstall
        
        var type: TrackableEventType {
            return .install
        }
        
        var message: String {
            switch self {
            case .organicInstall:
                return "App is now installed"
            case .deeplinkInstall:
                return "App is now installed with Deeplink"
            }
        }
    }
}
