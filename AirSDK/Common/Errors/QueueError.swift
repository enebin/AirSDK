//
//  QueueingError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/30.
//

import Foundation

enum QueueError: LocalizedError {
    case emptyInstallEvent
//    case invalidInstallEvent
    
    var errorDescription: String? {
        switch self {
        case .emptyInstallEvent:
            return "Install event is ignored."
        }
    }
    
}
