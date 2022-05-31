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
    private let trafficController: EventTrafficController
    
    // Working thread
    private let workQueue = DispatchQueue(label: "workQueue",
                                          qos: .utility,
                                          attributes: .concurrent)
    
    // Preventing data race by wrapping it with ThreadSafe
    private var customEventQueue = ThreadSafeArray(array: [TrackableEvent]())
    private var systemEventQueue = ThreadSafeArray(array: [TrackableEvent]())
    private var installEvent = ThreadSafeVariable<TrackableEvent>(element: nil)
    
    // ETC...
    private var isATTRequestProcessed = false
    
    // Initializer
    init(_ apiManager: AirAPIManager = AirAPIManager.shared,
         _ trafficController: EventTrafficController = EventTrafficController())
    {
        self.apiManager = apiManager
        self.trafficController = trafficController
        
        self.trafficController.delegate = self
    }
    
    // MARK: - Public methods
    
    /// Add the event to processing queue.
    ///
    ///
    /// The events will be handed to `NetworkManager`
    /// or waiting for being processed  by policies, `ConfigOption` given when the instance is configured
    func addToQueue(event: TrackableEvent) {
        switch event.type {
        case .custom:
            self.customEventQueue.append(event)
        case .install:
            self.installEvent.set(event)
        case .system:
            self.systemEventQueue.append(event)
        }
        
        // Emit remaining logs
        workQueue.async {
            self.emit()
        }
    }
    
    // MARK: - Internal methods
    
    /// Emit logs according to the given policies
    private func emit() {
        do {
            try self.emit(for: .custom)
            try self.emit(for: .system)
            
            // Check if ATT timeout is set
            if let ATTtimeout = self.options.waitingForATTAuthorizationWithTimeoutInterval,
               self.isATTRequestProcessed == false
            {
                // If ATT timeout set
                // Gives delay
                workQueue.asyncAfter(deadline: .now() + ATTtimeout) {
                    try? self.emit(for: .install)
                }
                
                self.isATTRequestProcessed = true
            } else {
                // If not
                // Emit right away
                try self.emit(for: .install)
            }
        }
        catch QueueError.EmptyEvent {
            if self.isATTRequestProcessed == false {
                LoggingManager.logger(error: QueueError.EmptyEvent)
            }
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
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

extension EventQueueManager: EventTrafficControllerDelegate {
    func emitSystemEvents() {
        do {
            try self.emit(for: .system)
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
    func emitCustomEvents() {
        do {
            try self.emit(for: .custom)
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
    func emitInstallEvents() {
        do {
            try self.emit(for: .install)
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
}
