//
//  QueueingError.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/30.
//

import Foundation

enum QueueError: LocalizedError {
    case EmptyEvent
    
    var errorDescription: String? {
        switch self {
        case .EmptyEvent:
            return "Event doesn't exsit."
        }
    }
    
}
