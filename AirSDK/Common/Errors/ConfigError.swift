//
//  AirConfigError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/12.
//

import Foundation

/// Possible errors can happen in AirSDK
enum ConfigError: LocalizedError {
    case alreadyInitialized
    case optionIsNotConfigured
    case notInitialized
    case autoStartIsAlreadyEnabled
    case alreadyStartedTracking
    
    var errorDescription: String? {
        switch self {
        case .alreadyInitialized:
            return "AirSDK has already been initialized"
        case .optionIsNotConfigured:
            return "AirConfigOptions instance is not configured"
        case .notInitialized:
            return "AirSDK has not been configured. Make sure you have configured SDK before"
        case .autoStartIsAlreadyEnabled:
            return "AirSDK has been configured to use automatic tracking. Make sure you've set auto-start value to `false` when configuring the option"
        case .alreadyStartedTracking:
            return "AirSDK has already started tracking before. It may affect the results of tracked events"
        }
    }
}
