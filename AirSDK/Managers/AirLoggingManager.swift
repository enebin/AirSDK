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
        print("[\(domain)] \(message)")
        
    }
    
    static func logger(error: Error) {
        print("[Error] \(error.localizedDescription)")
    }
}
