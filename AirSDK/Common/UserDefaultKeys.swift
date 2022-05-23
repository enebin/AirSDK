//
//  AirConstants.swift
//  
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation

/// Set of constants used for fetching `UserDefault` data
struct UserDefaultKeys {
    static let isInstalledKey = "isInstalled"
    static let lastRecordedSessionTimeKey = "sessionTime"
    
    @available(*, deprecated)
    static let isOpenedWithDeeplinkKey = "openedWithDeeplink"
}

