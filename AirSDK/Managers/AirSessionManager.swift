//
//  AirSession.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation

/// 세션 관리와 관련된 메소드를 제공하는 클래스입니다
class AirSessionManager {
    /// Unit is a second. 2 minutes by default
    static var validSessionTime: Double = 60 * (1/10)
    
    static func setSessionTimeToCurrentTime() {
        let currentTime = Date().timeIntervalSince1970
        UserDefaults.standard.set(currentTime, forKey: AirConstant.lastRecordedSessionTimeKey)
    }
    
    static func checkIfSessionIsVaild() -> Status {
        let currentTime = Date().timeIntervalSince1970
        if let sessionTime = AirCommon.lastRecordedSessionTime {
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
    enum Status: String {
        case expired = "Session time's out. It's expired."
        case valid = "Session's still valid"
        case unrecorded = "Session time is not recorded. There are several reasons, such as a fresh install or a mere error."
    }
}
