//
//  AirDeeplink.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// 딥링크를 관리하는 메소드를 제공하는 클래스입니다
class AirDeeplinkManager {
    static func handleSchemeLink(_ url: URL) throws {
        UserDefaults.standard.set(true, forKey: AirConstant.isOpenedWithDeeplinkKey)
        print("[AirDeeplink] Universal link's activated(\(url.absoluteString))")
        
        if false {
            throw URLError(.badURL)
        }
    }
    
    static func resetSchemeLinkStatus() {
        UserDefaults.standard.set(false, forKey: AirConstant.isOpenedWithDeeplinkKey)
    }
}
