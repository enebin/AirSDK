//
//  AirLoggingManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// Provide methods logging system history, including error messages.
class AirLoggingManager {
    static var method: LoggingMethod = .print
    
    static func logger(message: String, domain: String) {
        let log = "[AirSDK] [\(domain)] \(message)"
        self.shoutout(log)
    }
    
    static func logger(error: Error) {
        let log = "[AirSDK] [Error] \(error.localizedDescription)"
        self.shoutout(log)
    }
    
    static func logger(warning message: String) {
        let log = "[AirSDK] [Warning] \(message)"
        self.shoutout(log)
    }
    
    // MARK: - Internal methods
    
    static private func shoutout(_ log: String) {
        if self.method == .print {
            print(log)
        } else {
            NSLog(log)
        }
    }
}

extension AirLoggingManager {
    enum LoggingMethod {
        case print
        case NSLog
    }
}
