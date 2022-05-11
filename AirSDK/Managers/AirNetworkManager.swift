//
//  AirNetworkManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// 이 클래스는 서버와의 통신과 관련된 메소드를 제공합니다.
/// 현재는 네트워크 리퀘스트를 하지 않으므로 로컬 어플리케이션에 로그를 찍고 있습니다.
class AirNetworkManager {
    static func sendEventToServer(_ event: AirCommon.TrackableEvent) {
        AirLoggingManager.logger(message: event.message, domain: "AirSDK")
    }
}
