//
//  EventSemaphore.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/27.
//

import Foundation

class EventSemaphore {
    private let apiManager: AirAPIManager
    private var eventQueue = [AirTrackableEvent]()
    
    init(_ apiManager: AirAPIManager = AirAPIManager.shared) {
        self.apiManager = apiManager
    }
    
    func receiver(event: AirTrackableEvent) {
        
    }
    
    func emitter(event: AirTrackableEvent) {
        
    }
}


