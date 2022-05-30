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
    /// It's designed to solve problems when options getting configured before the SDK configured.
    /// This situation makes the SDK show logs even the `isDebug` option is set to `false`
    /// so this property is used to save change logs of the properties and
    /// decide to show logs according to the `isDebug` option with the fucntion `emitLogs`.
    private var logQueue = [String]()
    
    /// A number of seconds for a session timeout interval
    ///
    /// 2 minutes(120 seconds) by default
    public var sessionTimeoutInterval: TimeInterval = 60 * 2 {
        willSet {
            self.appendToLogQueue(#function, value: newValue)
        }
    }
    
    /// An option of whether to use the auto-starting or not
    ///
    /// Defined as `true` by default.
    ///
    /// - Warning: Do not change this value unless you have a specific reason.
    /// When it's `false`, SDK will not start tracking until you force to
    public var autoStartEnabled = true {
        willSet {
            self.appendToLogQueue(#function, value: newValue)
        }
    }
    
    /// An option of whether to show SDK's system logs or not
    public var isDebug = false {
        willSet {
            self.appendToLogQueue(#function, value: newValue)
        }
    }
    
    /// A number of seconds for ATT permission wait time interval
    ///
    /// 5 minutes(300 seconds) by default
    public var waitingForATTAuthorizationWithTimeoutInterval: TimeInterval? = nil {
        willSet {
            if self.autoStartEnabled == true {
                self.autoStartEnabled = false
            }
            
            self.appendToLogQueue(#function, value: newValue ?? 0)
        }
    }
    
    private mutating func appendToLogQueue(_ name: String, value: Any) {
        let log = "'\(name)' is set to \(value)."
        self.logQueue.append(log)
    }
    
    func emitLogs() {
        self.logQueue.forEach { log in
            LoggingManager.logger(message: log, domain: "AirConfigOptions")
        }
    }
    
    public init() {}
}
