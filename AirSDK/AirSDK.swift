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
    
    // MARK: - Public methods
    
    /// Initializes AirSDK with default configuration
    ///
    /// Configures a default AirSDK instance.
    /// Raises an error if any configuration step fails.
    ///
    /// - Warning: This method **should be called from the main thread**
    public static func configure() {
        do {
            try self.initialize(with: AirConfigOptions())
            LoggingManager.logger(message: "AirSDK is initialized", domain: "AirSDK.\(#function)")
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
            try self.initialize(with: options)
            LoggingManager.logger(message: "AirSDK is initialized", domain: "AirSDK.\(#function)")
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
            customEventManager.handleCustomEvent(TrackableEvents.customEvent(label: event))
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
            deeplinkManager.handleDeeplink(url) { result in
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
            deeplinkManager.handleDeeplink(url) { result in
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
            print("\(#function) called")
            try self.checkIfInitialzed(shared)
            
            guard let options = self.configuration else {
                throw ConfigError.optionIsNotConfigured
            }
            
            // For those who forgot disabling the auto-start...
            if options.autoStartEnabled {
                throw ConfigError.autoStartIsAlreadyEnabled
            }
            
            // Throwing an error if the AirSDK instance is not configured,
            // it guarantees that the options are set before this method is executed.
            // Consequently, no extra things required, for example, taking options as an argument
            try self.launchTrackers(options: options)
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
            try self.checkIfInitialzed(shared)
            
            self.removeTrackers()
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
    static private func initialize(with options: AirConfigOptions) throws {
        self.configuration = options

        if self.shared != nil {
            throw ConfigError.alreadyInitialized
        }

        self.shared = AirSDK()
        SessionManager.shared.configureWithOptions(options)
        LoggingManager.configureWithOptions(options)

//        if options.autoStartEnabled { // Change of policy
            try self.launchTrackers(options: options)
//        }
    }
    
    /// Start life cycle tracking
    ///
    /// - SeeAlso: `AirEventProcessor`
    static private func launchTrackers(options: AirConfigOptions) throws {
        if self.eventProcessor != nil {
            // FIXME: Decide depends on policies
            throw ConfigError.alreadyStartedTracking
        }
        self.eventProcessor = EventProcessor(options: options)
    }
    
    /// Start life cycle tracking with delay
    ///
    /// - SeeAlso: `setAndLaunchTrackers`
    static private func launchTrackersWithDelay(seconds: TimeInterval, options: AirConfigOptions) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            do {
                try self.launchTrackers(options: options)
            } catch let error {
                LoggingManager.logger(error: error)
            }
        }
    }
    
    /// Stop tracking
    static private func removeTrackers() {
        self.eventProcessor = nil
        LoggingManager.logger(message: "AirSDK is no longer tracking events", domain: "AirSDK.removeTrackers")
    }
}


