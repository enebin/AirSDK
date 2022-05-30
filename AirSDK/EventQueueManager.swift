//
//  EventSemaphore.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/27.
//

import Foundation

class EventQueueManager {
    // MARK: - Class' properties
    
    // Dependencies
    private let apiManager: AirAPIManager
    
    // Working dispatch queue
    private let workQueue = DispatchQueue(label: "workingQueue",
                                          qos: .utility,
                                          attributes: .concurrent)
    
    // Preventing data race by wrapping those
    private var customEventQueue = ThreadSafeArray(array: [TrackableEvent]())
    private var systemEventQueue = ThreadSafeArray(array: [TrackableEvent]())
    private var installEvent = ThreadSafeVariable<TrackableEvent>(element: nil)
    
    init(_ apiManager: AirAPIManager = AirAPIManager.shared) {
        self.apiManager = apiManager
    }
    
    // MARK: - Public methods
    
    func addQueue(event: TrackableEvent) {
        switch event.type {
        case .custom:
            self.customEventQueue.append(event)
        case .install:
            self.installEvent.set(event)
        case .system:
            self.systemEventQueue.append(event)
        }
        
        workQueue.async {
            try? self.emit()
        }
    }
    
    // MARK: - Internal methods
    
    /// Emitting all events in the given queue
    ///
    /// Recommended implementing in the background
    private func emit(for eventType: TrackableEvent.EventType? = nil) throws {
        print("EMITTING HERE", customEventQueue.count, systemEventQueue.count, installEvent.get() as Any)
        switch eventType {
        case .system:
            // Send systen events
            self.systemEventQueue.forEach { event in
                apiManager.sendEventToServer(event: event)
            }
            systemEventQueue.removeAll()
        case .install:
            // Sends an install event
            guard let event = self.installEvent.get() else {
                throw QueueError.EmptyEvent
            }
            apiManager.sendEventToServer(event: event)
            installEvent.remove()
        case .custom:
            // Send custom events
            self.customEventQueue.forEach { event in
                apiManager.sendEventToServer(event: event)
            }
            customEventQueue.removeAll()
        default:
            // Send all possible events
            // Install event
            if let event = self.installEvent.get() {
                apiManager.sendEventToServer(event: event)
                self.installEvent.remove()
            }
            
            // System events
            self.systemEventQueue.forEach { event in
                // TODO: Maybe need error handling
                apiManager.sendEventToServer(event: event)
            }
            
            // Custom events
            self.customEventQueue.forEach { event in
                // TODO: Maybe need error handling
                apiManager.sendEventToServer(event: event)
            }
            
            systemEventQueue.removeAll()
            customEventQueue.removeAll()
        }
    }
}

extension EventQueueManager {
    enum EventCategory {
        case system
        case custom
        case install
    }
}
