//
//  AirLoggingManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// 로그를 기록하기 위한 메소드를 제공하는 클래스입니다.
class AirLoggingManager {
    static func logger(message: String, domain: String) {
        print("[\(domain)] \(message)")
    }
}
