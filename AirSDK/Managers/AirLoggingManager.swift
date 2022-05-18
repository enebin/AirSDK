//
//  AirLoggingManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// Provide methods related to logging system history, including error messages.
class AirLoggingManager {
    static func logger(message: String, domain: String) {
        let log = "[\(domain)] \(message)"
        print(log)
//        NSLog(log)
    }
    
    static func logger(error: Error) {
        let log = "[AirSDK Error] \(error.localizedDescription)"
        //        print("[Error] \(error.localizedDescription)")

        NSLog(log)
    }
}
