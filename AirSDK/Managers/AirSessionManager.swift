//
//  AirSession.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation

/// A class handling the app session
///
/// It is recommended to being generated only once
class AirSessionManager {
    static let shared = AirSessionManager()
    
    /// Unit is a second. 2 minutes by default
    private var validSessionTime: Double = 60 * (1/20)
    
    func configureWithOptions(_ options: AirConfigOptions) {
        self.validSessionTime = options.sessionTime
    }
    
    func setSessionTimeToCurrent() {
        let currentTime = Date().timeIntervalSince1970
        UserDefaults.standard.set(currentTime, forKey: UserDefaultKeys.lastRecordedSessionTimeKey)
    }
    
    /// Check the current session's status
    ///
    /// - Returns: There are three possible statuses a session can have:
    /// `valid`, `expired`, `unrecorded`.
    /// Check description of `Status` for the details.
    func checkIfSessionIsVaild() -> Status {
        let currentTime = Date().timeIntervalSince1970
        if let sessionTime = PersistentVariables.lastRecordedSessionTime {
            if currentTime - sessionTime < validSessionTime {
                return .valid
            } else {
                return .expired
            }
        } else {
            return .unrecorded
        }
    }
}

extension AirSessionManager {
    /// Possible status a session can have
    @frozen enum Status: String {
        /// The app is opened **after** session time is expired
        case expired = "Session time's out. It's expired."
        
        /// The app is opened **before** session time is expired
        case valid = "Session's still valid"
        
        /// For unknown reasons, session time is not recorded
        case unrecorded = "Session time is not recorded. There are several reasons, such as a fresh install or a mere error."
    }
}
