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
    private let options: AirConfigOptions
    
    // Working dispatch queue
    private let workQueue = DispatchQueue(label: "workingQueue",
                                          qos: .utility,
                                          attributes: .concurrent)
    
    // Preventing data race by wrapping it
    private var customEventQueue = ThreadSafeArray(array: [Trackable]())
    private var systemEventQueue = ThreadSafeArray(array: [Trackable]())
    private var installEvent = ThreadSafeVariable<Trackable>(element: nil)
    
    // Initializer
    init(_ apiManager: AirAPIManager = AirAPIManager.shared,
         options: AirConfigOptions)
    {
        self.apiManager = apiManager
        self.options = options
    }
    
    // MARK: - Public methods
    
    func addQueue(event: Trackable) {
        switch event.type {
        case .custom:
            self.customEventQueue.append(event)
        case .install:
            self.installEvent.set(event)
        case .system:
            self.systemEventQueue.append(event)
        }
        
        workQueue.async {
            do {
                try self.emitAll()
            }
            catch let error {
                LoggingManager.logger(error: error)
            }
        }
    }
    
    // MARK: - Internal methods
    
    /// Emitting all events in the given queue
    ///
    /// Recommended implementing in the background
    private func emit(for eventType: TrackableEventType) throws {
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
        }
    }
    
    /// Emitting all events in all the exsisting queues
    ///
    /// Recommended implementing in the background
    private func emitAll() throws {
        // Send all possible events
        // Install event
        if let event = self.installEvent.get() {
            apiManager.sendEventToServer(event: event)
            installEvent.remove()
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
