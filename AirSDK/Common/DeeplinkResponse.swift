//
//  DeeplinkResponse.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/16.
//

import Foundation

struct DeeplinkResponse: Decodable {
    let appName: String
    let deeplink: String
    let fallback: String
    
    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case deeplink, fallback
    }
}
