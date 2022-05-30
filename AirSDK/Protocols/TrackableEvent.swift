//
//  TrackableEventP.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/30.
//

import Foundation

protocol TrackableEvent {
    var type: TrackableEventType { get }
    var message: String { get }
}
