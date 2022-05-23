//
//  AirDeeplinkError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/16.
//

import Foundation

/// Possible errors can happen in networking
enum AirDeeplinkError: LocalizedError {
    case invalidUrl
    case invalidHost
    case invalidQueryItems
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidHost:
            return "Invalid scheme is received"
        case .invalidUrl:
            return "Invalid url is received"
        case .invalidQueryItems:
            return "Failed to parse query items"
        case .unknown:
            return "Unknown error"
        }
    }
}
