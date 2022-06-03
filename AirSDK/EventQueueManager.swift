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
    private let apiManager: APIManager
    private let options: AirConfigOptions
    private let trafficController: EventTrafficController
    
    // Working thread
    private let workQueue = DispatchQueue(label: "workQueue",
                                          qos: .utility,
                                          attributes: .concurrent)
    
    // Preventing data race by wrapping it with ThreadSafe
    private var customEventQueue = ThreadSafeArray(array: [TrackableEvent]())
    private var systemEventQueue = ThreadSafeArray(array: [TrackableEvent]())
    private var installEvent = ThreadSafeVariable<TrackableEvent>(element: nil)
    
    // Traffic lights...
    private var isSystemEventEmitable = false
    private var isCustomEventEmitable = false
    private var isInstallEventEmitable = false
    
    // Initializer
    init(_ apiManager: APIManager = APIManager.shared,
         _ trafficController: EventTrafficController = EventTrafficController(),
         options: AirConfigOptions
    )
    {
        self.apiManager = apiManager
        self.trafficController = trafficController
        self.options = options
        
        self.trafficController.delegate = self
    }
    
    // MARK: - Public methods
    
    /// Add the event to processing queue.
    ///
    /// The events will be handed to `NetworkManager`
    /// or waiting for being processed  by policies, `ConfigOption` given when the instance is configured
    func addToQueue(event: TrackableEvent) {
//        print("Event \(event.message) added to the queue")
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
    
    // MARK: - Private methods
    
    /// Emit logs according to the given policies
    private func emit() {
        if self.isInstallEventEmitable {
            emit(for: .install)
        }
        
        if self.isSystemEventEmitable {
            emit(for: .system)
        }
        
        if self.isCustomEventEmitable {
            emit(for: .custom)
        }
    }
    
    /// Emitting all events in the given queue
    ///
    /// Recommended implementing in the background
    private func emit(for eventType: TrackableEventType) {
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
                return
            }
            apiManager.sendEventToServer(event: event)

            self.isInstallEventEmitable = false
            installEvent.remove()
        case .custom:
            // Send custom events
            self.customEventQueue.forEach { event in
                apiManager.sendEventToServer(event: event)
            }
   
            customEventQueue.removeAll()
        }
    }
}

extension EventQueueManager: EventTrafficControllerDelegate {
    func systemEventDidBecomeEmitable() {
        self.isSystemEventEmitable = true
        self.emit()
    }
    
    func customEventDidBecomeEmitable() {
        self.isCustomEventEmitable = true
        self.emit()
    }
    
    func installEventDidBecomeEmitable() {
        self.isInstallEventEmitable = true
        self.emit()
    }
    
    func trackingDidBecomeDisabled() {
        self.isInstallEventEmitable = false
        self.isCustomEventEmitable = false
        self.isSystemEventEmitable = false
    }
}
