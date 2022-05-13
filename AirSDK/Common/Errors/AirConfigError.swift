//
//  AirConfigError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/12.
//

import Foundation

/// Possible errors can happen in AirSDK
@frozen enum AirConfigError: LocalizedError {
    case alreadyInitialized
    case notInitialized
    
    var errorDescription: String? {
        switch self {
        case .alreadyInitialized:
            return "AirSDK has already been initialized"
        case .notInitialized:
            return "AirSDK has not been configured properly. SDK may not work as you expected."
        }
    }
}
