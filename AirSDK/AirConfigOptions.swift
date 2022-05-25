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
    /// A number of seconds for a session timeout interval
    ///
    /// 2 minutes(120 seconds) by default
    public var sessionTimeoutInterval: TimeInterval = 60 * 2 {
        willSet {
            AirLoggingManager.logger(message: "'sessionTimeoutInterval' is set to \(newValue). ", domain: "AirConfigOptions")
        }
    }
    
    /// A number of seconds for ATT permission wait time interval
    ///
    /// 5 minutes(300 seconds) by default
    public var ATTtimeoutInterval: TimeInterval = 60 * 5 {
        willSet {
            AirLoggingManager.logger(message: "'ATTtimeoutInterval' is set to \(newValue).", domain: "AirConfigOptions")
        }
    }
    
    /// Save the option of whether to use the auto-starting or not
    ///
    /// Defined as `true` by default.
    ///
    /// - Warning: Do not change this value unless you have a specific reason.
    /// When it's `false`, SDK will not start tracking until you force to
    public var autoStartEnabled = true {
        willSet {
            AirLoggingManager.logger(message: "'autoStartEnabled' is set to \(newValue).", domain: "AirConfigOptions")
        }
    }
    
    public init() {}
}
