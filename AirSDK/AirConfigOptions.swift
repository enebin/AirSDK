//
//  AirConfiguration.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/15.
//

import Foundation

/// Contain  user adjustable options
///
/// Submitting without any modifications, SDK will be configured with default values.
public struct AirConfigOptions {
    ///
    public var sessionTime: Double = 60 * 2
    
    public init() {}
}
