//
//  AirTrackableEvent.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/11.
//

import Foundation

//enum TrackableEvent {
//    case organicInstall
//    case organicOpen
//    case organicReOpen
//    case active
//    case background
//    case deeplinkInstall
//    case deeplinkOpen
//    case deeplinkReOpen
//    case custom(label: String)
//
//    enum EventType {
//        case system
//        case install
//        case custom
//    }
//
//    var message: String {
//        switch self {
//        case .organicInstall:
//            return "App is now installed"
//        case .organicOpen:
//            return "App is opened"
//        case .organicReOpen:
//            return "App is reopened"
//        case .active:
//            return "App become active"
//        case .background:
//            return "App enters background"
//        case .deeplinkInstall:
//            return "App is now installed with Deeplink"
//        case .deeplinkOpen:
//            return "App is opened with Deeplink"
//        case .deeplinkReOpen:
//            return "App is reopened with Deeplink"
//        case .custom(let label):
//            return label
//        }
//    }
//
//    var type: EventType {
//        switch self {
//        case .organicInstall:
//            return .install
//        case .deeplinkInstall:
//            return .install
//        case .organicOpen:
//            return .system
//        case .organicReOpen:
//            return .system
//        case .active:
//            return .system
//        case .background:
//            return .system
//        case .deeplinkOpen:
//            return .system
//        case .deeplinkReOpen:
//            return .system
//        case .custom(_):
//            return .custom
//        }
//    }
//}


protocol Trackable {
    var type: TrackableEventType { get }
}

enum TrackableEventType {
    case system
    case install
    case custom
}

struct TrackableEvents {
    struct CustomEvent: Trackable {
        let type: TrackableEventType = .custom
        let label: String
    }
    
    enum SystemEvent: Trackable {
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
    
    enum InstallEvent: Trackable {
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
