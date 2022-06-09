//
//  AirSDK.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation
import UIKit

/// Main class of the SDK
public class AirSDK {
    // MARK: - Instances
    static var shared: AirSDK?
    static var eventProcessor: EventProcessor?
    static var configuration: AirConfigOptions?

    // Dependencies
    static let customEventManager = CustomEventManager.shared
    static let deeplinkManager = DeeplinkManager.shared
    static let eventTrafficManager = EventTrafficSignalSender.shared
    
    // MARK: - Public methods
    
    /// Initializes AirSDK with default configuration
    ///
    /// Configures a default AirSDK instance.
    /// Raises an error if any configuration step fails.
    ///
    /// - Warning: This method **should be called from the main thread**
    public static func configure() {
        do {
            let defaultOptions = AirConfigOptions()
            try self._configure(with: defaultOptions)
            LoggingManager.logger(message: "AirSDK is initialized", domain: "System")
        } catch let error {
            // FIXME: Handle errors in here
            LoggingManager.logger(error: error)
        }
    }
            
    /// Initializes AirSDK with given options
    ///
    /// Configures the instance with customized options.
    /// Raises an error if any configuration step fails.
    ///
    /// - Parameters:
    ///     - AirConfigOptions : `Struct` containing options to operate SDK
    ///
    /// - Warning: This method **should be called from the main thread**.
    public static func configure(with options: AirConfigOptions) {
        do {
            try self._configure(with: options)
            LoggingManager.logger(message: "AirSDK is initialized", domain: "System")
        } catch let error {
            // FIXME: Handle errors in here
            LoggingManager.logger(error: error)
        }
    }
    
    /// Sends a user defined event to the server
    ///
    /// Raises an error if any step fails.
    public static func sendCustomEvent(_ event: String) {
        do {
            try checkIfInitialzed(shared)
            self.customEventManager.handleCustomEvent(TrackableEvents.customEvent.custom(message: event))
        } catch ConfigError.notInitialized {
            fatalError(ConfigError.notInitialized.localizedDescription)
        } catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
    /// Handle deeplink received
    ///
    /// Commonly usable
    ///
    /// - Parameters:
    ///     - url: Deeplink url
    public static func handleDeepLink(_ url: URL) {
        do {
            try checkIfInitialzed(shared)
            self.deeplinkManager.handleDeeplink(url) { result in
                switch result {
                case .failure(let error):
                    LoggingManager.logger(error: error)
                case .success(_):
                    break
                }
            }
        } catch ConfigError.notInitialized {
            fatalError(ConfigError.notInitialized.localizedDescription)
        } catch let error {
            LoggingManager.logger(error: error)
        }
    }

    /// Handle received deeplink by passing it as a parameter
    ///
    /// Regardless of scheme or universal link it handle every routines
    /// which should be done before sending it to the server
    ///
    /// - Parameters:
    ///     - url: A Deeplink url
    ///     - completion: A completion closure for `Result` variable containing `URL` or an error
    ///
    public static func handleDeepLink(_ url: URL, completion: @escaping (URL?) -> Void) {
        do {
            try checkIfInitialzed(shared)
            self.deeplinkManager.handleDeeplink(url) { result in
                switch result {
                case .failure(let error):
                    LoggingManager.logger(error: error)
                    completion(nil)
                case .success(let url):
                    completion(url)
                }
            }
        } catch ConfigError.notInitialized {
            fatalError(ConfigError.notInitialized.localizedDescription)
        } catch let error {
            LoggingManager.logger(error: error)
            completion(nil)
        }
    }
    
    /// Start event tracking manually
    ///
    /// You must have configured when
    ///
    /// - Warning: Make sure you have set auto-start value in `AirConfigOptions` to `false`.
    ///     If not, it's likely that the SDK has already tracked the event much earlier,
    ///     so data may contain unexpected values.
    public static func startTracking() {
        do {
            guard let options = self.configuration else {
                throw ConfigError.optionsAreNotConfigured
            }
            
            // For those who forgot disabling the auto-start...
            if options.autoStartEnabled == true {
                throw ConfigError.autoStartIsAlreadyEnabled
            }
            
            try self._startTracking(options: options)
        }
        catch ConfigError.notInitialized {
            fatalError(ConfigError.notInitialized.localizedDescription)
        }
        catch ConfigError.autoStartIsAlreadyEnabled {
            fatalError(ConfigError.autoStartIsAlreadyEnabled.localizedDescription)
        }
        catch ConfigError.alreadyStartedTracking {
            fatalError(ConfigError.alreadyStartedTracking.localizedDescription)
        }
        catch ConfigError.optionsAreNotConfigured {
            fatalError(ConfigError.optionsAreNotConfigured.localizedDescription)
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
    
    /// Wait for ATT permission with time interval.
    /// Default value is 5 minutes(300 seconds).
    @available(*, deprecated)
    public static func waitForATTtimeoutInteval(seconds: TimeInterval = 300) {
        do {
            try self._waitForATTtimeoutInteval(seconds: seconds)
        }
        catch ConfigError.notInitialized {
            fatalError(ConfigError.notInitialized.localizedDescription)
        }
        catch ConfigError.autoStartIsAlreadyEnabled {
            fatalError(ConfigError.autoStartIsAlreadyEnabled.localizedDescription)
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
    /// Stop event tracking manually
    public static func stopTracking() {
        do {
            try self._stopTracking()
        }
        catch ConfigError.notInitialized {
            fatalError(ConfigError.notInitialized.localizedDescription)
        }
        catch let error {
            LoggingManager.logger(error: error)
        }
    }
    
    // MARK: - Internal methods
    
    /// Checks if SDK has been initialized properly
    ///
    /// - Throws:`AirConfigError.notInitialized`
    ///      if SDK hasn't been configured before.
    static private func checkIfInitialzed(_ instance: AirSDK?) throws {
        if instance == nil {
            throw ConfigError.notInitialized
        }
    }
    
    /// Wraps Initializing routine of the SDK
    /// and configure other dependancies with the given options.
    static private func _configure(with options: AirConfigOptions) throws {
        self.configuration = options

        if self.shared != nil {
            throw ConfigError.alreadyInitialized
        }

        self.shared = AirSDK()
        SessionManager.shared.configureWithOptions(options)
        LoggingManager.configureWithOptions(options)

        try self.launchTracker(options: options)
    }
    
    /// Makes a tracker instance and gets ready for tracking life cycle
    ///
    /// - SeeAlso: `AirEventProcessor`
    static private func launchTracker(options: AirConfigOptions) throws {
        self.eventProcessor = EventProcessor(options: options)
        
        if options.autoStartEnabled {
            try self._startTracking(options: options)
        }
    }
    
    /// Start tracking and send the events to the server
    ///
    /// What's different from `launchTracker`?
    /// - `launchTracker` just makes an instance and adds the events to the queue.
    ///      To send the events to the server, you should execute this method.
    /// - To avoid making another instance of `EventProcessor`, public method `startTracker` executes this method instead of excuting `launchTracker`.
    static private func _startTracking(options: AirConfigOptions) throws {
        try self.checkIfInitialzed(shared)
        
        guard let options = self.configuration else {
            throw ConfigError.optionsAreNotConfigured
        }
        
        // Checks ATT timeout and prepare to send the event
        self.eventTrafficManager.waitingForATT(timeout: options.waitingForATTtimeoutInterval ?? 0)
        
        // Enables tracking
        try self.eventTrafficManager.startTracking()
        
        LoggingManager.logger(message: "AirSDK is now tracking events and sending them to the server.", domain: "System")
    }
    
    /// Inner method that handles ATT timeout inside SDK
    @available(*, deprecated)
    static private func _waitForATTtimeoutInteval(seconds: TimeInterval) throws {
        try self.checkIfInitialzed(shared)
        self.eventTrafficManager.waitingForATT(timeout: seconds)
        
        LoggingManager.logger(message: "ATT timeout is set to \(seconds).", domain: "System")
    }
    
    static private func _stopTracking() throws {
        try self.checkIfInitialzed(shared)
        self.eventTrafficManager.stopTracking()
        
        LoggingManager.logger(message: "AirSDK is no longer tracking events", domain: "System")
    }
}


