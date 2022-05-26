//
//  AirConfigError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/12.
//

import Foundation

/// Possible errors can happen in AirSDK
enum AirConfigError: LocalizedError {
    case alreadyInitialized
    case notInitialized
    case autoStartIsEnabled
    case alreadyStartedTracking
    
    var errorDescription: String? {
        switch self {
        case .alreadyInitialized:
            return "AirSDK has already been initialized"
        case .notInitialized:
            return "AirSDK has not been configured. Make sure you have configured SDK before."
        case .autoStartIsEnabled:
            return "AirSDK has been configured to use automatic tracking. Make sure you've set auto-start value to `false` when configuring the option."
        case .alreadyStartedTracking:
            return "AirSDK has already started tracking before. It may affect the results of tracked events."
        }
    }
}
