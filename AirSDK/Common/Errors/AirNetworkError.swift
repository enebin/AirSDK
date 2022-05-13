//
//  AirError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/11.
//

import Foundation

/// Possible errors can happen in networking
@frozen enum AirNetworkError: LocalizedError {
    case invalidEvent
    case internalServerError
    case badRequest
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEvent:
            return "Invalid event"
        case .internalServerError:
            return "Internal server error"
        case .badRequest:
            return "Bad request"
        case .unknown:
            return "Unknown error"
        }
    }
}
