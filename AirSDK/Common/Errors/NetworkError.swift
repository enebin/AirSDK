//
//  AirError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/11.
//

import Foundation

/// Possible errors can happen in networking
enum NetworkError: LocalizedError {
    case invalidEvent
    case internalServerError
    case invalidUrl
    case badRequest
    case unableToDecode(error: Error)
    case unableToGetData
    case unableToGetResponse
    case unknown(error: Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidEvent:
            return "Invalid event"
        case .internalServerError:
            return "Internal server error"
        case .invalidUrl:
            return "Invalid url"
        case .badRequest:
            return "Bad request"
        case .unableToDecode(let error):
            return "Unable to decode received data: \(error) \(error.localizedDescription)"
        case .unableToGetData:
            return "Unable to get data from network response"
        case .unableToGetResponse:
            return "Unable to get a response from the server"
        case .unknown(let error):
            return "Unknown error with: \(error.localizedDescription)"
        }
    }
}
