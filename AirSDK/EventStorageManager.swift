//
//  EventStorageManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/06/03.
//

import Foundation

//
class EventStorageManager {
    // Depedencies
    let apiManager: APIManager
    
    @Stored("StoredEvents") var storedQueue: [EncodedEvent]
    
    init(apiManager: APIManager = APIManager.shared) {
        self.apiManager = apiManager
        self.storedQueue.append(EncodedEvent(event: TrackableEvents.systemEvent.active))
        print(self.storedQueue)
    }
}

struct EncodedEvent: Codable {
    let uuid: UUID
    let event: String
    
    init(event: TrackableEvent) {
        self.uuid = UUID()
        self.event = event.message
    }
}
