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
    case unableToDecode
    case unableToGetData
    case unableToGetResponse
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEvent:
            return "Invalid event"
        case .internalServerError:
            return "Internal server error"
        case .badRequest:
            return "Bad request"
        case .unableToDecode:
            return "Unable to decode received data"
        case .unableToGetData:
            return "Unable to get data from network response"
        case .unableToGetResponse:
            return "Unable to get a response from the server"
        case .unknown:
            return "Unknown error"
        }
    }
}
